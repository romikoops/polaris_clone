# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class ChargeCategory < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::ChargeCategory.new(state: state, target_frame: target_frame).perform
        end

        def error_reason(row:)
          "The charge '#{row['fee_code']} - #{row['fee_name']}' cannot be found."
        end
      end
    end
  end
end
