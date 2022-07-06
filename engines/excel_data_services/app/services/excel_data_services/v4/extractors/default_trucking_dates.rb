# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class DefaultTruckingDates < ExcelDataServices::V4::Extractors::Base
        def frame_data
          [
            { "effective_date" => Time.zone.today, "expiration_date" => 1.year.from_now.to_date, "join_value" => nil }
          ]
        end

        def join_arguments
          { "effective_date" => "join_value", "expiration_date" => "join_value" }
        end

        def frame_types
          { "effective_date" => :object, "expiration_date" => :object }
        end
      end
    end
  end
end
