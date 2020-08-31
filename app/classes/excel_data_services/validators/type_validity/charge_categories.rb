# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class ChargeCategories < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'internal_code': :optional_string,
          'fee_code': :string,
          'fee_name': :optional_string
        }.freeze
      end
    end
  end
end
