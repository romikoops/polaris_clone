# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      module ZoneRanges
        class SingleZoneRangeExpanded
          def self.data(frame:, country_code:, identifier:)
            new(frame: frame, country_code: country_code, identifier: identifier).data
          end

          def initialize(frame:, country_code:, identifier:)
            @frame = frame
            @country_code = country_code
            @identifier = identifier
          end

          def data
            return result_zone_range if identifier == "distance" || postal_zone_range.blank?

            result_zone_range.inner_join(postal_zone_range, on: { identifier => identifier })
          end

          private

          attr_reader :country_code, :frame, :identifier

          def result_zone_range
            @result_zone_range ||= Rover::DataFrame.new(expanded_country_ranges)
          end

          def expanded_country_ranges
            sanitized_range_rows
              .flat_map { |range| SingleCountryRangeExpanded.data(country_code: country_code, range: range, identifier: identifier) }
              .compact
          end

          def sanitized_range_rows
            rows = frame[frame["country_code"] == country_code]
            rows[!rows["range"].missing]["range"].to_a
          end

          def postal_zone_range
            @postal_zone_range ||= Rover::DataFrame.new(postal_codes.map { |postal_code| { identifier => postal_code, "country_code" => country_code } }) if postal_codes.present?
          end

          def postal_codes
            @postal_codes ||= ::Trucking::PostalCodes.for(country_code: country_code.downcase)
          end
        end
      end
    end
  end
end
