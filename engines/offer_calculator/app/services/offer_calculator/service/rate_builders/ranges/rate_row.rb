# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      module Ranges
        class RateRow
          def initialize(row:)
            @row = row
          end

          attr_reader :row

          def covers(input:)
            (range_min...range_max).cover?(input)
          end

          def monetized_value
            Money.new(value * 100, currency)
          end

          def monetized_min_value
            Money.new(min_value * 100, currency)
          end

          def monetized_max_value
            Money.new(max_value * 100, currency)
          end

          def rate_basis
            row.dig("rate", "rate_basis")
          end

          def value
            row.dig("rate", "rate") || row.dig("rate", "value")
          end

          def currency
            row.dig("rate", "currency")
          end

          def base
            row.dig("rate", "base")
          end

          def min_value
            row["min_value"] || 0
          end

          def max_value
            row["max_value"] || OfferCalculator::Service::RateBuilders::Base::DEFAULT_MAX
          end

          def range_max
            row[max_key].to_d
          end

          def range_min
            row[min_key].to_d
          end

          def max_key
            row.keys.find { |key| key.include?("max_") && key.exclude?("_value") }
          end

          def min_key
            row.keys.find { |key| key.include?("min_") && key.exclude?("_value") }
          end
        end
      end
    end
  end
end
