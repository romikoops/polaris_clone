# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class LocationsLocation < ExcelDataServices::V4::Extractors::Base
        private

        def extracted
          @extracted ||= extracted_location_variants.inject(non_location_based_frame) do |result_frame, variant|
            result_frame.concat(variant)
          end
        end

        def extracted_location_variants
          [
            extracted_locode_locations,
            extracted_postal_code_locations,
            extracted_city_locations
          ].compact
        end

        def frame_data
          Locations::Location
            .where(country_code: country_codes)
            .select("id as locations_location_id, name as location_name, UPPER(country_code) as country_code")
        end

        def extracted_locode_locations
          @extracted_locode_locations ||= locode_rows.left_join(extracted_frame, on: { "locode" => "location_name" }) if locode_rows.present?
        end

        def extracted_postal_code_locations
          @extracted_postal_code_locations ||= postal_code_rows.left_join(extracted_frame, on: { "postal_code" => "location_name", "country_code" => "country_code" }) if postal_code_rows.present?
        end

        def extracted_city_locations
          @extracted_city_locations ||= if city_rows.present?
            Rover::DataFrame.new(
              city_rows.to_a.map do |row|
                row.merge("locations_location_id" => LocationIdFromRow.new(row: row, identifier: identifier).perform)
              end
            )
          end
        end

        def frame_types
          { "location_id" => :object }
        end

        def country_codes
          @country_codes ||= frame["country_code"].to_a.uniq.map(&:downcase)
        end

        def location_based_rows
          @location_based_rows ||= frame[frame["query_type"] == QueryType::QUERY_TYPE_ENUM["location"]]
        end

        def non_location_based_rows
          @non_location_based_rows ||= frame[frame["query_type"] != QueryType::QUERY_TYPE_ENUM["location"]]
        end

        def postal_code_rows
          @postal_code_rows ||= location_based_rows.filter({ "identifier" => "postal_code" })
        end

        def locode_rows
          @locode_rows ||= frame.filter({ "identifier" => "locode" })
        end

        def city_rows
          @city_rows ||= frame.filter({ "identifier" => "city" })
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def non_location_based_frame
          @non_location_based_frame ||= non_location_based_rows.left_join(non_location_based_id_frame, on: { "query_type" => "query_type" })
        end

        def non_location_based_id_frame
          @non_location_based_id_frame ||= Rover::DataFrame.new(
            QueryType::QUERY_TYPE_ENUM.except("location").values.map do |enum_value|
              { "locations_location_id" => nil, "query_type" => enum_value }
            end
          )
        end

        class LocationIdFromRow
          def initialize(row:, identifier:)
            @row = row
            @identifier = identifier
          end

          def perform
            location&.id
          end

          private

          attr_reader :row, :identifier

          def prepared_data
            @prepared_data ||= ExcelDataServices::V4::Helpers::GeoDataPreparer.data(identifier: identifier, raw_data: row)
          end

          def location
            @location ||= ::Locations::LocationSearcher.get(identifier: identifier).data(data: prepared_data)
          end
        end
      end
    end
  end
end
