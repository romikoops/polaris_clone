# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class TruckingLocation < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[country_id].freeze

        def insertable_data
          frame[[identifier, "country_id", "locations_location_id", "query_type"]].to_a.uniq.map do |trucking_location_row|
            trucking_location_row["location_id"] = trucking_location_row.delete("locations_location_id")
            trucking_location_row["data"] = trucking_location_row.delete(identifier)
            trucking_location_row["query"] = trucking_location_row.delete("query_type")
            trucking_location_row
          end
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end
      end
    end
  end
end
