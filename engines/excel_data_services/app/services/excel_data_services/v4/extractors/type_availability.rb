# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class TypeAvailability < ExcelDataServices::V4::Extractors::Base
        def extracted
          @extracted ||= blank_frame
            .concat(combined_frame_for_extraction)
            .left_join(extracted_frame, on: join_arguments)[metadata_frame.keys + %w[type_availability_id country_id]]
        end

        def frame_data
          Trucking::TypeAvailability.where(country_id: country_ids, query_method: query_methods)
            .select(" id as type_availability_id, truck_type, carriage, load_type, country_id")
        end

        def join_arguments
          {
            "truck_type" => "truck_type",
            "carriage" => "carriage",
            "load_type" => "load_type",
            "country_id" => "country_id"
          }
        end

        def frame_types
          {
            "truck_type" => :object,
            "carriage" => :object,
            "load_type" => :object,
            "country_id" => :object
          }
        end

        def query_methods
          @query_methods ||= zone_frame["query_method"].to_a.uniq
        end

        def country_ids
          @country_ids ||= zone_frame["country_id"].uniq.to_a
        end

        def zone_frame
          @zone_frame ||= state.frame("zones")
        end

        def rate_frame
          @rate_frame ||= state.frame("rates")
        end

        def zone_and_sheet_name
          @zone_and_sheet_name ||= rate_frame[%w[zone sheet_name organization_id]].uniq
        end

        def zone_and_country_id
          @zone_and_country_id ||= zone_frame[%w[zone country_id organization_id]].uniq
        end

        def metadata_frame
          @metadata_frame ||= state.frame("default")
        end

        def combined_frame_for_extraction
          @combined_frame_for_extraction ||= combined_frame[desired_keys].uniq
        end

        def desired_keys
          metadata_frame.keys + ["country_id"]
        end

        def combined_frame
          @combined_frame ||= zone_and_country_id
            .left_join(zone_and_sheet_name, on: { "zone" => "zone", "organization_id" => "organization_id" })
            .left_join(metadata_frame, on: { "sheet_name" => "sheet_name", "organization_id" => "organization_id" })
        end
      end
    end
  end
end
