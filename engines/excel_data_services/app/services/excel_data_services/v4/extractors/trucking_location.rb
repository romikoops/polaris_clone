# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class TruckingLocation < ExcelDataServices::V4::Extractors::Base
        def extracted
          non_location_based_rows.left_join(extracted_frame, on: join_arguments).concat(
            location_based_rows.left_join(extracted_frame, on: join_arguments.except(identifier))
          )
        end

        def frame_data
          Trucking::Location.joins(:country).where(countries: { code: country_codes }, query: query_types)
            .select(
              "trucking_locations.id as trucking_location_id,
              trucking_locations.data AS trucking_location_name,
              trucking_locations.location_id as locations_location_id,
              trucking_locations.query,
              countries.code as country_code"
            )
        end

        def join_arguments
          {
            identifier => "trucking_location_name",
            "locations_location_id" => "locations_location_id",
            "country_code" => "country_code"
          }
        end

        def country_codes
          frame["country_code"].uniq.to_a
        end

        def frame_types
          {
            "trucking_location_id" => :object,
            "trucking_location_name" => :object,
            "country_code" => :object,
            "query" => :object
          }
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def query_types
          @query_types ||= frame["query_type"].to_a.uniq
        end

        def non_location_based_rows
          @non_location_based_rows ||= frame[frame["query_type"] != QueryType::QUERY_TYPE_ENUM["location"]]
        end

        def location_based_rows
          @location_based_rows ||= frame[frame["query_type"] == QueryType::QUERY_TYPE_ENUM["location"]]
        end
      end
    end
  end
end
