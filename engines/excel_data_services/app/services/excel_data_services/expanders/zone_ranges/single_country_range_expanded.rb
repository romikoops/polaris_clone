# frozen_string_literal: true
module ExcelDataServices
  module Expanders
    module ZoneRanges
      class SingleCountryRangeExpanded
        def self.data(secondary_range:, country_code:)
          new(country_code: country_code, secondary_range: secondary_range).data
        end

        def initialize(secondary_range:, country_code:)
          @country_code = country_code
          @secondary_range = secondary_range
        end

        def data
          return alphanumeric_range if secondary_range.match?(/[A-Z]/)

          numeric_range
        end

        private

        attr_reader :secondary_range, :country_code

        def alphanumeric_range
          alpha = range_start[/[A-Z]{1,}/]
          min = range_start[/[0-9]{1,}/]
          max = range_end[/[0-9]{1,}/]

          min.upto(max).map do |numeric|
            {
              "primary" => [alpha, numeric].join,
              "country_code" => country_code,
              "secondary" => secondary_range
            }
          end
        end

        def range_start
          @range_start ||= min_and_max.first
        end

        def range_end
          @range_end ||= min_and_max.last
        end

        def min_and_max
          @min_and_max ||= secondary_range.split("-").map(&:strip)
        end

        def numeric_range
          (range_start...range_end).map do |numeric|
            {
              "primary" => numeric,
              "country_code" => country_code,
              "secondary" => secondary_range
            }
          end
        end
      end
    end
  end
end
