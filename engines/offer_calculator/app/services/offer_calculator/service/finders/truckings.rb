# frozen_string_literal: true

module OfferCalculator
  module Service
    module Finders
      class Truckings < OfferCalculator::Service::Finders::Base
        def perform
          return ::Trucking::Trucking.none if targets.empty?

          first_target = targets.first
          base_query = carriage_association(carriage: first_target, groups: hierarchy,
                                            hub_ids: hub_ids_by_carriage(target: first_target))
          return base_query if targets.length == 1
          last_target = targets.last
          base_query.or(
            carriage_association(carriage: last_target, groups: hierarchy,
                                 hub_ids: hub_ids_by_carriage(target: last_target))
          )
        end

        private

        def targets
          @targets ||= {
            "pre" => shipment.has_pre_carriage? ? true : nil,
            "on" => shipment.has_on_carriage? ? true : nil
          }.compact.keys
        end

        def hub_ids_by_carriage(target:)
          target == "pre" ? schedules.map(&:origin_hub_id) : schedules.map(&:destination_hub_id)
        end

        def carriage_association(carriage:, hub_ids:, groups:)
          args = {
            address: address_for_carriage(carriage: carriage),
            load_type: shipment.load_type,
            organization_id: shipment.organization_id,
            cargo_classes: cargo_classes,
            carriage: carriage,
            hub_ids: hub_ids,
            order_by: "group_id",
            groups: groups
          }

          results = ::Trucking::Queries::Availability.new(args).perform
          return results if results.empty? || hierarchy.empty?

          results.where(id: selected_trucking_ids(results: results, carriage: carriage))
        end

        def selected_trucking_ids(results:, carriage:)
          filter_combos(results: results, carriage: carriage).map { |filters|
            cargo_class, hub_id, truck_type, tenant_vehicle_id = filters
            target_trucking = nil
            hierarchy_with_nil.each do |group|
              next if target_trucking.present?

              target_trucking = results.find_by(
                group: group,
                hub_id: hub_id,
                truck_type: truck_type,
                tenant_vehicle_id: tenant_vehicle_id,
                cargo_class: cargo_class
              )
            end

            target_trucking&.id
          }.compact
        end

        def filter_combos(results:, carriage:)
          cargo_classes.product(
            valid_hub_ids(results: results),
            truck_types(carriage: carriage),
            results.pluck(:tenant_vehicle_id).uniq
          )
        end

        def hierarchy_with_nil
          hierarchy | [nil]
        end

        def cargo_classes
          @cargo_classes ||= @shipment.cargo_classes
        end

        def trucking_details
          @trucking_details ||= @shipment.trucking
        end

        def valid_hub_ids(results:)
          valid_ids(
            collection: results.pluck(:hub_id).uniq,
            association: results,
            filter_column: "hub_id",
            select: :cargo_class
          )
        end

        def truck_types(carriage:)
          truck_type_for_carriage(carriage: carriage) || default_truck_types
        end

        def default_truck_types
          @shipment.fcl? ? Trucking::Trucking::FCL_TRUCK_TYPES : Trucking::Trucking::LCL_TRUCK_TYPES
        end

        def address_for_carriage(carriage:)
          if carriage == "pre"
            quotation.pickup_address
          else
            quotation.delivery_address
          end
        end

        def truck_type_for_carriage(carriage:)
          assigned_truck_type = trucking_details.dig("#{carriage}_carriage", "truck_type")
          return if assigned_truck_type.blank?

          [assigned_truck_type]
        end
      end
    end
  end
end
