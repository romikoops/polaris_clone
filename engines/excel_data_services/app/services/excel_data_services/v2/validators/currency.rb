# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Currency < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::Currency.state(state: default_extracted)
        end

        def default_extracted
          @default_extracted ||= ExcelDataServices::V2::Extractors::DefaultCurrency.state(state: state)
        end

        def error_reason(row:)
          "The currency '#{row['currency']}' is not valid under the ISO4217 standard"
        end

        def required_key
          "currency_id"
        end
      end
    end
  end
end
