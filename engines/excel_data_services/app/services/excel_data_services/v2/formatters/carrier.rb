# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class Carrier < ExcelDataServices::V2::Formatters::Base
        # This class will pull the Carrier info out of the row and return the data ready for insertion
        ATTRIBUTE_KEYS = %w[carrier].freeze

        def insertable_data
          sliced_frame = frame[ATTRIBUTE_KEYS]
          sliced_frame["name"] = sliced_frame["carrier"]
          sliced_frame["code"] = sliced_frame["carrier"].map(&:downcase)
          sliced_frame.delete("carrier")
          sliced_frame.to_a.uniq
        end
      end
    end
  end
end
