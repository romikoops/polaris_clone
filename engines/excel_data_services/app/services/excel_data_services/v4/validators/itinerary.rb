# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Itinerary < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Itinerary.state(state: state)
        end

        def error_reason(row:)
          "The route '#{row['origin']} - #{row['destination']}' cannot be found."
        end
      end
    end
  end
end
