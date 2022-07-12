# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class ExpandedFee
          def initialize(fee:, base:)
            @fee = fee
            @base = base
          end

          attr_reader :fee, :base

          def perform
            value_keys.product(range).map do |value_key, range_row|
              base_row.merge(
                OfferCalculator::Service::Charges::Support::ValueExtractor.new(
                  value_key: value_key,
                  range: range_row.merge("rate_basis" => fee["rate_basis"])
                ).perform
              )
            end
          end

          private

          def range
            @range ||= fee.delete("range").presence || [fee.except("min", "max")]
          end

          def base_row
            @base_row ||= base.merge(fee).except(*fallback_value_keys)
          end

          def value_key_service
            @value_key_service ||= OfferCalculator::Service::Charges::Support::ValueKeys.new(fee: fee)
          end

          delegate :value_keys, :fallback_value_keys, to: :value_key_service
        end
      end
    end
  end
end
