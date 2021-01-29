# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      module Routing
        class Carriage < OfferCalculator::Service::OfferCreators::Routing::Base
          private

          def trucking
            @trucking ||= offer_data.first.object.original
          end

          def from
            @from ||= outbound? ? request.pickup_address : trucking.hub
          end

          def to
            @to ||= outbound? ? trucking.hub : request.delivery_address
          end

          def mode_of_transport
            "carriage"
          end

          def outbound?
            section.include?("pre")
          end
        end
      end
    end
  end
end
