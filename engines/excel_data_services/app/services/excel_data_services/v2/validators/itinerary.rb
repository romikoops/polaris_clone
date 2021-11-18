# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Itinerary < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::Itinerary.state(state: state)
        end

        def error_reason(row:)
          "The route '#{row['origin']} - #{row['destination']}' cannot be found."
        end

        def required_key
          "itinerary_id"
        end
      end
    end
  end
end
