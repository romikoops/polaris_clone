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
            extracted_postal_city_locations,
            extracted_city_locations
          ].compact
        end

        def frame_data
          Locations::Location
            .where(country_code: country_codes)
            .select("id as locations_location_id, name as location_name, UPPER(country_code) as country_code")
        end

        def extracted_locode_locations
          return if locode_rows.blank?

          @extracted_locode_locations ||= locode_rows.left_join(extracted_frame, on: { "locode" => "location_name" }).tap do |tapped_frame|
            tapped_frame["trucking_location_name"] = tapped_frame["locode"]
          end
        end

        def extracted_postal_code_locations
          return if postal_code_rows.empty?

          @extracted_postal_code_locations ||= postal_code_rows.left_join(extracted_frame, on: { "postal_code" => "location_name", "country_code" => "country_code" }).tap do |tapped_frame|
            tapped_frame["trucking_location_name"] = tapped_frame["postal_code"]
          end
        end

        def extracted_city_locations
          @extracted_city_locations ||= if city_rows.present?
            Rover::DataFrame.new(
              city_rows.to_a.map do |row|
                row.merge("trucking_location_name" => row["city"], "locations_location_id" => LocationIdFromRow.new(row: row, identifier: identifier).perform)
              end
            )
          end
        end

        def extracted_postal_city_locations
          @extracted_postal_city_locations ||= (PostalCityRows.new(frame: postal_city_rows, location_data: extracted_frame).perform if postal_city_rows.present?)
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
          @postal_code_rows ||= location_based_rows[location_based_rows["city"].missing].filter({ "identifier" => "postal_code" })
        end

        def locode_rows
          @locode_rows ||= location_based_rows.filter({ "identifier" => "locode" })
        end

        def city_rows
          @city_rows ||= location_based_rows.filter({ "identifier" => "city" })
        end

        def postal_city_rows
          @postal_city_rows ||= location_based_rows.filter({ "identifier" => "postal_city" })
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def non_location_based_frame
          @non_location_based_frame ||= non_location_based_rows.left_join(non_location_based_id_frame, on: { "query_type" => "query_type" }).tap do |tapped_frame|
            tapped_frame["trucking_location_name"] = tapped_frame[identifier]
          end
        end

        def non_location_based_id_frame
          @non_location_based_id_frame ||= Rover::DataFrame.new(
            QueryType::QUERY_TYPE_ENUM.except("location").values.map do |enum_value|
              { "locations_location_id" => nil, "query_type" => enum_value }
            end
          )
        end

        class PostalCityRows
          def initialize(frame:, location_data:)
            @frame = frame
            @location_data = location_data
          end

          attr_reader :frame, :location_data

          def perform
            cities_containing_postal_code.concat(
              Rover::DataFrame.new(postal_codes_containing_city_with_location_id)
            ).concat(rows_not_needing_extraction)
          end

          def cities_containing_postal_code
            @cities_containing_postal_code ||= duplicate_city_rows.left_join(location_data, on: { "postal_code" => "location_name", "country_code" => "country_code" }).tap do |tapped_frame|
              tapped_frame["trucking_location_name"] = tapped_frame["postal_code"]
            end
          end

          def postal_codes_containing_city_with_location_id
            @postal_codes_containing_city_with_location_id ||= rows_still_needing_extraction.to_a.map do |row|
              row.merge("trucking_location_name" => row["city"], "locations_location_id" => LocationIdFromRow.new(row: row, identifier: "postal_city").perform)
            end
          end

          def rows_still_needing_extraction
            @rows_still_needing_extraction ||= rows_extracted_from_trucking_location[rows_extracted_from_trucking_location["locations_location_id"].missing]
          end

          def rows_not_needing_extraction
            @rows_not_needing_extraction ||= rows_extracted_from_trucking_location[!rows_extracted_from_trucking_location["locations_location_id"].missing]
          end

          def rows_extracted_from_trucking_location
            @rows_extracted_from_trucking_location ||= duplicate_postal_rows.left_join(trucking_location_frame, on: { "city" => "trucking_location_name", "country_code" => "country_code" })
          end

          def trucking_location_frame
            @trucking_location_frame ||= Rover::DataFrame.new(
              Trucking::Location.joins(:country)
              .where(countries: { code: country_codes }, query: "location", identifier: "postal_city")
              .where.not(location_id: nil)
              .select(
                "trucking_locations.id as trucking_location_id,
                trucking_locations.data AS trucking_location_name,
                trucking_locations.location_id as locations_location_id,
                trucking_locations.query,
                countries.code as country_code"
              )
            )
          end

          def duplicate_cities
            @duplicate_cities ||= city_by_count.select { |_city, count| count > 1 }.keys
          end

          def duplicate_city_rows
            @duplicate_city_rows ||= frame[frame["city"].in?(duplicate_cities)]
          end

          def duplicate_postal_rows
            @duplicate_postal_rows ||= frame[!frame["row"].in?(duplicate_city_rows["row"])]
          end

          def city_by_count
            @city_by_count ||= frame["city"].tally
          end

          def country_codes
            @country_codes ||= frame["country_code"].to_a.uniq
          end
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
