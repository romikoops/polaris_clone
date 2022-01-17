# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class Carrier < ExcelDataServices::V3::Formatters::Base
        # This class will pull the Carrier info out of the row and return the data ready for insertion
        ATTRIBUTE_KEYS = %w[carrier].freeze

        def insertable_data
          sliced_frame = rows_for_insertion[ATTRIBUTE_KEYS]
          sliced_frame["name"] = sliced_frame["carrier"]
          sliced_frame["code"] = sliced_frame["carrier"].map(&:downcase)
          sliced_frame.delete("carrier")
          sliced_frame.to_a.uniq
        end

        def target_attribute
          "carrier_id"
        end
      end
    end
  end
end
