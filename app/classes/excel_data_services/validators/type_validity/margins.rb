# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Margins < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'expiration_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'origin': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'country_origin': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'destination': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'country_destination': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'mot': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'carrier': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'service_level': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'margin_type': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'load_type': ExcelDataServices::Validators::TypeValidity::Types::CargoClassType,
          'fee_code': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'operator': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'margin': ExcelDataServices::Validators::TypeValidity::Types::StringType
        }.freeze
      end
    end
  end
end
