# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class PrimaryFeeCode < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::PrimaryFeeCode.state(state: state)
        end

        def required_key
          "fee_code"
        end
      end
    end
  end
end
