# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class ValueExtractor
          attr_reader :value_key, :range

          def initialize(value_key:, range:)
            @value_key = value_key
            @range = range
          end

          def perform
            fee_range_data.merge(rate_value)
          end

          private

          def fee_range_data
            {
              "range_min" => range.values_at("min", "range_min").find(&:present?) || 0,
              "range_max" => range.values_at("max", "range_max").find(&:present?) || Float::INFINITY,
              "range_unit" => value_key,
              "rate_basis" => rate_basis
            }
          end

          def rate_value
            { "rate" => range[active_rate_key] }
          end

          def fall_back_rate_keys
            keys = [value_key, "rate", "value"]
            keys += %w[ton cbm] if value_key == "stowage_factor"
            keys
          end

          def active_rate_key
            @active_rate_key ||= fall_back_rate_keys.find { |key| range[key].present? }
          end

          def rate_basis
            @rate_basis ||= OfferCalculator::Service::Charges::Support::RateBasisData.new(fee: range).rate_basis
          end
        end
      end
    end
  end
end
