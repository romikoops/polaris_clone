# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      module Routing
        class Transfer < OfferCalculator::Service::OfferCreators::Routing::Base
          private

          def local_charge
            @local_charge ||= offer_data.first.object.original
          end

          def from
            @from ||= local_charge.hub
          end

          def to
            @to ||= from
          end

          def mode_of_transport
            local_charge.mode_of_transport
          end
        end
      end
    end
  end
end
