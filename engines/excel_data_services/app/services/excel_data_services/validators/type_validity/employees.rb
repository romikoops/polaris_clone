# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Employees < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'company_name': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'first_name': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'last_name': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'email': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'password': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'phone': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'vat_number': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'external_id': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'address': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
        }.freeze
      end
    end
  end
end
