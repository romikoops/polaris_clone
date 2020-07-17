# frozen_string_literal: true

module OfferCalculator
  module Service
    module Finders
      class LocalCharges < OfferCalculator::Service::Finders::Base
        def perform
          valid_local_charges.where(id: selected_local_charge_ids)
        end

        private

        def valid_local_charges
          @valid_local_charges ||= organization_local_charges.where(tenant_vehicle_id: valid_tenant_vehicle_ids)
        end

        def organization_local_charges
          @organization_local_charges ||=
            Legacy::LocalCharge.where(organization: shipment.organization, load_type: cargo_classes)
              .for_dates(start_date, end_date)
        end

        def selected_local_charge_ids
          (selected_origin_local_charge_ids(target: "export") |
            selected_origin_local_charge_ids(target: "import")).compact
        end

        def selected_origin_local_charge_ids(target:)
          return [] unless local_charges_required(target: target)

          hub_pairings.map do |cargo_class, origin, destination|
            hub = target == "export" ? origin : destination
            counterpart = target == "export" ? destination : origin
            charges = association_for_target(target: target).where(
              hub_id: hub,
              load_type: cargo_class,
              counterpart_hub_id: counterpart
            )
            if charges.empty?
              charges = charges.rewhere(
                hub_id: hub,
                load_type: cargo_class,
                counterpart_hub_id: nil
              )
            end

            next if charges.blank?

            target_group = hierarchy.find { |group| charges.exists?(group_id: group.id) }

            charges.find_by(group_id: target_group&.id)&.id
          end
        end

        def association_for_target(target:)
          target == "export" ? origin_local_charges : destination_local_charges
        end

        def origin_local_charges
          valid_local_charges.where(direction: "export")
        end

        def destination_local_charges
          valid_local_charges.where(direction: "import")
        end

        def valid_tenant_vehicle_ids
          @valid_tenant_vehicle_ids ||=
            valid_ids(
              collection: tenant_vehicle_ids,
              association: organization_local_charges,
              filter_column: "tenant_vehicle_id",
              select: :load_type
            )
        end

        def tenant_vehicle_ids
          @tenant_vehicle_ids ||= schedules.map { |schedule| schedule.trip.tenant_vehicle_id }
        end

        def hub_pairings
          @hub_pairings ||= uniq_route_schedules.flat_map { |schedule|
            shipment.cargo_classes.map do |cargo_class|
              [cargo_class, schedule.origin_hub_id, schedule.destination_hub_id]
            end
          }
        end

        def uniq_route_schedules
          schedules.uniq { |schedule| [schedule.origin_hub_id, schedule.destination_hub_id] }
        end

        def origin_hubs
          @origin_hubs ||= ::Legacy::Hub.where(id: schedules.map(&:origin_hub_id))
        end

        def destination_hubs
          @destination_hubs ||= ::Legacy::Hub.where(id: schedules.map(&:destination_hub_id))
        end

        def local_charges_required(target:)
          target == "export" ? export_required? : import_required?
        end

        def export_required?
          shipment.has_pre_carriage? || origin_mandatory_charges
        end

        def import_required?
          shipment.has_on_carriage? || destination_mandatory_charges
        end

        def origin_mandatory_charges
          origin_hubs.exists?(mandatory_charge: export_mandatory_charges)
        end

        def destination_mandatory_charges
          destination_hubs.exists?(mandatory_charge: import_mandatory_charges)
        end

        def export_mandatory_charges
          ::Legacy::MandatoryCharge.where(export_charges: true)
        end

        def import_mandatory_charges
          ::Legacy::MandatoryCharge.where(import_charges: true)
        end
      end
    end
  end
end
