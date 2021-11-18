# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class PrimaryFeeCode < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::PrimaryFeeCode.state(state: state)
        end

        def required_key
          "fee_code"
        end
      end
    end
  end
end
