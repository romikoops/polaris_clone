# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class RateBasisData
          attr_reader :fee, :base

          def initialize(fee:)
            @fee = fee
          end

          def rate_basis
            case original_rate_basis
            when /_FLAT\z/
              "PER_SHIPMENT"
            when "PER_UNIT_TON_CBM_RANGE"
              stowage_rate_basis
            else
              original_rate_basis
            end
          end

          private

          def original_rate_basis
            fee["rate_basis"]
          end

          def stowage_rate_basis
            if fee.key?("ton")
              "PER_TON"
            else
              "PER_CBM"
            end
          end
        end
      end
    end
  end
end
