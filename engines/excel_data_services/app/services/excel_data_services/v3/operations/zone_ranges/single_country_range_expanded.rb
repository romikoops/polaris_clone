# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      module ZoneRanges
        class SingleCountryRangeExpanded
          def self.data(range:, country_code:, identifier:)
            new(country_code: country_code, range: range, identifier: identifier).data
          end

          def initialize(range:, country_code:, identifier:)
            @country_code = country_code
            @range = range
            @identifier = identifier
          end

          def data
            return alphanumeric_range if range.match?(/[A-Z]/)

            numeric_range
          end

          private

          attr_reader :range, :country_code, :identifier

          def alphanumeric_range
            min.upto(max).map do |numeric|
              {
                identifier => [alpha, numeric].join,
                "country_code" => country_code,
                "range" => range
              }
            end
          end

          def alpha
            range_start[/[A-Z]{1,}/]
          end

          def min
            range_start[/[0-9]{1,}/]
          end

          def max
            range_end[/[0-9]{1,}/]
          end

          def range_start
            @range_start ||= min_and_max.first
          end

          def range_end
            @range_end ||= min_and_max.last
          end

          def min_and_max
            @min_and_max ||= range.split("-").map(&:strip)
          end

          def numeric_range
            (range_start...range_end).map do |numeric|
              {
                identifier => numeric,
                "country_code" => country_code,
                "range" => range
              }
            end
          end
        end
      end
    end
  end
end
