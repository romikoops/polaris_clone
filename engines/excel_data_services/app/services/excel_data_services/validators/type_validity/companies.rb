# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Companies < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'name': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'email': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'phone': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'vat_number': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'address': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
        }.freeze
      end
    end
  end
end
