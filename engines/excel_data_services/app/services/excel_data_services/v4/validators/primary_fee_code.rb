# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class PrimaryFeeCode < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::PrimaryFeeCode.new(state: state, target_frame: target_frame).perform
        end

        def required_key
          "fee_code"
        end
      end
    end
  end
end
