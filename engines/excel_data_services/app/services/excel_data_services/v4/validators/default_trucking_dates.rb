# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class DefaultTruckingDates < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::DefaultTruckingDates.state(state: state)
        end

        def required_key
          "effective_date"
        end
      end
    end
  end
end
