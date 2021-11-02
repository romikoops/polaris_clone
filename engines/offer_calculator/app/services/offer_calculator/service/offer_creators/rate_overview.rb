# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class RateOverview
        BUFFER = 5
        def self.overview(result:)
          new(result: result).perform
        end

        def initialize(result:)
          @result = result
        end

        def perform
          manipulated_pricings.each_with_object({}) { |rate, result| result[rate.cargo_class] = rate.fees }
        end

        private

        attr_reader :result

        delegate :itinerary, :legacy_service, :load_type, :issued_at, :query, to: :result

        def pricings
          @pricings ||= Pricings::Pricing.where(
            itinerary: itinerary,
            load_type: load_type,
            tenant_vehicle: legacy_service
          ).for_dates(
            issued_at, (issued_at + BUFFER.days)
          )
        end

        def manipulated_pricings
          return [] if pricings.empty?

          OfferCalculator::Service::Manipulators::Pricings.results(
            association: pricings,
            request: request,
            schedules: [temp_schedule]
          )
        end

        def temp_schedule
          OfferCalculator::Schedule.new(
            id: SecureRandom.uuid,
            mode_of_transport: itinerary.mode_of_transport,
            transshipment: itinerary.transshipment,
            eta: issued_at + BUFFER.days,
            etd: issued_at + 1.day,
            closing_date: issued_at,
            origin_hub_id: itinerary.origin_hub_id,
            destination_hub_id: itinerary.destination_hub_id,
            origin_hub_name: itinerary.origin_hub.name,
            destination_hub_name: itinerary.destination_hub.name,
            vehicle_name: legacy_service.name,
            carrier_name: legacy_service&.carrier&.name,
            trip_id: SecureRandom.uuid,
            itinerary_id: itinerary.id,
            tenant_vehicle_id: legacy_service.id,
            load_type: load_type,
            carrier_lock: legacy_service.carrier_lock,
            carrier_id: legacy_service.carrier_id
          )
        end

        def request
          OfferCalculator::Request.new(query: query.object, params: {})
        end
      end
    end
  end
end
