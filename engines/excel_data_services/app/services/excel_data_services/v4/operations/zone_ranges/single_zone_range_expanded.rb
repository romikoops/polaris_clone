# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      module ZoneRanges
        class SingleZoneRangeExpanded
          NUMERIC_ONLY_COUNTRIES = %w[NL].freeze
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
            rows[!rows["range"].missing]["range"].to_a.uniq
          end

          def postal_zone_range
            @postal_zone_range ||= Rover::DataFrame.new(postal_codes.map { |postal_code| { identifier => sanitized_postal_code(postal_code: postal_code), "country_code" => country_code } }) if postal_codes.present?
          end

          def postal_codes
            @postal_codes ||= trucking_postal_codes.presence || legacy_postal_codes
          end

          def trucking_postal_codes
            @trucking_postal_codes ||= ::Trucking::PostalCode.joins(:country).where(countries: { code: country_code.upcase }).pluck(:postal_code)
          end

          def legacy_postal_codes
            @legacy_postal_codes ||= ::Trucking::PostalCodes.for(country_code: country_code.downcase)
          end

          def sanitized_postal_code(postal_code:)
            if numeric_postal_code_only?
              postal_code.delete("[a-zA-Z]$").strip
            else
              postal_code
            end
          end

          def numeric_postal_code_only?
            @numeric_postal_code_only ||= NUMERIC_ONLY_COUNTRIES.include?(country_code)
          end
        end
      end
    end
  end
end
