# frozen_string_literal: true

module OfferCalculator
  module Service
    module Finders
      class Pricings < OfferCalculator::Service::Finders::Base
        def perform
          organization_pricings.where(id: selected_pricing_ids.compact).distinct
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
            next if target_group.nil?

            pricings.where(group_id: target_group&.id).ids
          end
        end

        def validation_combos
          itineraries.ids.product(tenant_vehicles.ids, [request.cargo_classes])
        end

        def organization_pricings
          pricings_association.for_load_type(request.load_type)
        end

        def itineraries
          @itineraries ||= ::Legacy::Itinerary.where(id: schedules.map(&:itinerary_id)).distinct
        end

        def tenant_vehicles
          @tenant_vehicles ||= ::Legacy::TenantVehicle.where(id: schedules.map(&:tenant_vehicle_id)).distinct
        end

        def pricings_association
          ::Pricings::Pricing.where(
            internal: false,
            tenant_vehicle_id: tenant_vehicles,
            itinerary: itineraries,
            organization_id: request.organization.id
          ).for_dates(start_date, end_date)
        end

        def exclude_default
          scope[:dedicated_pricings_only]
        end
      end
    end
  end
end
