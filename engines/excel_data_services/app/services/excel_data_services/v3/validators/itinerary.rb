# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class Itinerary < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::Itinerary.state(state: state)
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
