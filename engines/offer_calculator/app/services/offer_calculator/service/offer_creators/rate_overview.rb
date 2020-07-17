# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class RateOverview
        def self.overview(offer:)
          new(offer: offer).perform
        end

        def initialize(offer:)
          @offer = offer
        end

        def perform
          (rates | manipulated_pricings)
            .each_with_object({}) do |rate, result|
              result[rate.cargo_class] = rate.fees
            end
        end

        private

        attr_reader :offer

        def rates
          @rates ||= offer.section(key: "cargo").map(&:object).uniq
        end

        def pricings
          @pricings ||= Pricings::Pricing.where(
            itinerary: itinerary,
            load_type: load_type,
            tenant_vehicle_id: tenant_vehicle_id
          ).for_dates(
            rates.first.effective_date, rates.first.expiration_date
          ).where.not(
            cargo_class: rates.map(&:cargo_class)
          )
        end

        def itinerary
          @itinerary ||= offer.itinerary
        end

        def tenant_vehicle_id
          @tenant_vehicle_id ||= offer.tenant_vehicle(section_key: "cargo")
        end

        def load_type
          @load_type ||= offer.load_type
        end

        def manipulated_pricings
          OfferCalculator::Service::Manipulators::Pricings.results(
            association: pricings,
            shipment: offer.shipment,
            schedules: [offer.schedules.first]
          )
        end
      end
    end
  end
end
