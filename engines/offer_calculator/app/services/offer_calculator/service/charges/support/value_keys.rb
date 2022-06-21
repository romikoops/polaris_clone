# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class ValueKeys
          attr_reader :fee

          def initialize(fee:)
            @fee = fee
          end

          def value_keys
            @value_keys ||= if stowage?
              ["stowage_factor"]
            elsif range_unit
              [range_unit]
            else
              rate_basis
                .gsub("BILL", "SHIPMENT")
                .gsub("CONTAINER", "UNIT")
                .split("_")
                .reject { |part| part.in?(%w[PER X RANGE FLAT]) }
                .map(&:downcase)
            end
          end

          def fallback_value_keys
            @fallback_value_keys ||= value_keys + %w[rate value]
          end

          private

          def rate_basis
            fee["rate_basis"]
          end

          def stowage?
            rate_basis == "PER_UNIT_TON_CBM_RANGE"
          end

          def range_unit
            @range_unit ||= fee["range_unit"]
          end
        end
      end
    end
  end
end
