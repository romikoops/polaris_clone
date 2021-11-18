# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class ChargeCategory < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::ChargeCategory.state(state: state)
        end

        def error_reason(row:)
          "The charge '#{row['fee_code']} - #{row['fee_name']}' cannot be found."
        end

        def required_key
          "charge_category_id"
        end
      end
    end
  end
end
