# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class TruckingLocation < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[trucking_location_name country_id locations_location_id query_type identifier upsert_id].freeze

        def insertable_data
          data_with_corrected_headers.to_a
        end

        def data_with_corrected_headers
          zone_frame[ATTRIBUTE_KEYS].tap do |tapped_frame|
            tapped_frame["location_id"] = tapped_frame.delete("locations_location_id")
            tapped_frame["data"] = tapped_frame.delete("trucking_location_name")
            tapped_frame["query"] = tapped_frame.delete("query_type")
            tapped_frame.uniq
          end
        end

        def zone_frame
          @zone_frame ||= state.frame("zones")
        end
      end
    end
  end
end
