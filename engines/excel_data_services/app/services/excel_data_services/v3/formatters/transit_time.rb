# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class TransitTime < ExcelDataServices::V3::Formatters::Base
        ATTRIBUTE_KEYS = %w[tenant_vehicle_id transit_time transit_time_id itinerary_id].freeze

        def insertable_data
          sliced_frame = frame[ATTRIBUTE_KEYS]
          sliced_frame["duration"] = sliced_frame.delete("transit_time")
          sliced_frame["id"] = sliced_frame.delete("transit_time_id")
          sliced_frame[!sliced_frame["duration"].missing].to_a.uniq
        end
      end
    end
  end
end
