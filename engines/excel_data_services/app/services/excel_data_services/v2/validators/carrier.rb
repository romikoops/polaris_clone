# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Carrier < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::Carrier.state(state: state)
        end

        def error_reason(row:)
          "The carrier '#{row['carrier']}' cannot be found."
        end

        def required_key
          "carrier_id"
        end
      end
    end
  end
end
