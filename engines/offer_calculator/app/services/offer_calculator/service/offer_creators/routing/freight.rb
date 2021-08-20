# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      module Routing
        class Freight < OfferCalculator::Service::OfferCreators::Routing::Base
          private

          def itinerary
            @itinerary ||= offer.itinerary
          end

          def from
            @from ||= itinerary.origin_hub
          end

          def to
            @to ||= itinerary.destination_hub
          end

          def mode_of_transport
            itinerary.mode_of_transport
          end

          def transshipment
            itinerary.transshipment
          end

          def transit_time
            Legacy::TransitTime.find_by(itinerary: itinerary, tenant_vehicle: tenant_vehicle)&.duration ||
              OfferCalculator::Schedule::DURATION
          end
        end
      end
    end
  end
end
