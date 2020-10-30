# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class ChargeCategories < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'internal_code': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'fee_code': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'fee_name': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
        }.freeze
      end
    end
  end
end
