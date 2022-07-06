# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Currency < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Currency.state(state: default_extracted)
        end

        def default_extracted
          @default_extracted ||= ExcelDataServices::V4::Extractors::DefaultCurrency.new(state: state, target_frame: target_frame).perform
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
