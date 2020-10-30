module ExcelDataServices
  module Expanders
    module ZoneRanges
      class SingleZoneRangeExpanded
        def self.data(frame:, country_code:)
          new(frame: frame, country_code: country_code).data
        end

        def initialize(frame:, country_code:)
          @frame = frame
          @country_code = country_code
        end

        def data
          return result_zone_range if identifier == "distance" || postal_zone_range.blank?

          result_zone_range.inner_join(postal_zone_range, on: {"primary" => "primary"})
        end

        private

        attr_reader :country_code, :frame

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def result_zone_range
          @result_zone_range ||= Rover::DataFrame.new(expanded_country_ranges)
        end

        def expanded_country_ranges
          sanitized_range_rows
            .flat_map { |range| SingleCountryRangeExpanded.data(country_code: country_code, secondary_range: range) }
            .compact
        end

        def sanitized_range_rows
          rows = frame[frame["country_code"] == country_code]
          rows[!rows["secondary"].missing]["secondary"].to_a
        end

        def postal_zone_range
          @postal_zone_range ||= begin
            postal_codes = ::Trucking::PostalCodes.for(country_code: country_code.downcase)
            return if postal_codes.blank?

            Rover::DataFrame.new(
              postal_codes.map { |postal_code| {"primary" => postal_code, "country_code" => country_code} }
            )
          end
        end
      end
    end
  end
end
