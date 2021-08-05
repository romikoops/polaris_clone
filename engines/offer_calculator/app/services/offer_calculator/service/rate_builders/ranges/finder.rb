# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      module Ranges
        class Finder
          STANDARD_RANGE_KEYS = OfferCalculator::Service::RateBuilders::Lookups::STANDARD_RANGE_KEYS
          UNIT_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::UNIT_RATE_BASES

          LimitExceeded = Class.new(StandardError)
          RangesMissed = Class.new(StandardError)

          def initialize(range:, measure:, key:)
            @range = range
            @measure = measure
            @key = key
          end

          def rate
            @rate ||= upper_rate || range_rate || floor_fallback
          end

          def error
            @error ||= if rate
              nil
            elsif scope["hard_trucking_limit"] && measured_value > range_max
              OfferCalculator::Errors::LoadMeterageExceeded
            else
              OfferCalculator::Errors::TruckingRateNotFound
            end
          end

          attr_reader :range, :measure, :key

          private

          delegate :scope, to: :measure

          def upper_rate
            rate_rows.last if !scope["hard_trucking_limit"] && measured_value > range_max
          end

          def rate_rows
            @rate_rows ||= range.map { |row| RateRow.new(row: row) }.sort_by(&:range_min)
          end

          def range_rate
            @range_rate ||= rate_rows.find { |rate_row| rate_row.covers(input: measured_value) }
          end

          def floor_fallback
            first_rate_row if measured_value < range_min
          end

          def first_rate_row
            @first_rate_row ||= rate_rows.first
          end

          def last_rate_row
            @last_rate_row ||= rate_rows.last
          end

          delegate :range_min, :min_value, :rate_basis, to: :first_rate_row
          delegate :range_max, :max_value, to: :last_rate_row

          def measured_value
            @measured_value ||= begin
              total_value = case key
                            when "unit_in_kg"
                              measure.chargeable_weight
                            else
                              measure.send(key)
              end

              scaled_value = if UNIT_RATE_BASES.include?(rate_basis)
                total_value.scale(1.0 / measure.quantity)
              else
                total_value
              end
              scaled_value.value
            end
          end
        end
      end
    end
  end
end
