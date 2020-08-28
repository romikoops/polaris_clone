# frozen_string_literal: true

module OfferCalculator
  module Service
    module Finders
      class Pricings < OfferCalculator::Service::Finders::Base
        def perform
          organization_pricings.where(id: selected_pricing_ids.compact)
        end

        private

        def selected_pricing_ids
          validation_combos.flat_map do |combo|
            itinerary_id, tenant_vehicle_id, cargo_classes = combo
            pricings = organization_pricings.where(
              itinerary_id: itinerary_id,
              tenant_vehicle_id: tenant_vehicle_id,
              cargo_class: cargo_classes
            )
            target_group = hierarchy.find { |group|
              pricings.where(group_id: group.id).pluck(:cargo_class).to_set == cargo_classes.to_set
            }
            next if scope[:dedicated_pricings_only] && target_group.nil?

            pricings.where(group_id: target_group&.id).ids
          end
        end

        def validation_combos
          itineraries.ids.product(tenant_vehicles.ids, [shipment.cargo_classes])
        end

        def organization_pricings
          pricings_association.for_load_type(shipment.load_type)
        end

        def itineraries
          @itineraries ||= ::Legacy::Itinerary.where(id: schedules.map(&:itinerary_id))
        end

        def tenant_vehicles
          @tenant_vehicles ||= ::Legacy::TenantVehicle.where(id: schedules.map(&:tenant_vehicle_id))
        end

        def pricings_association
          ::Pricings::Pricing.where(
            internal: false,
            tenant_vehicle_id: tenant_vehicles,
            itinerary: itineraries,
            organization_id: shipment.organization_id
          ).for_dates(start_date, end_date)
        end
      end
    end
  end
end
