# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class LocalCharges < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'expiration_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'hub': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'country': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'fee': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'counterpart_hub': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'counterpart_country': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'service_level': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'carrier': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'fee_code': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'direction': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'rate_basis': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'mot': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'load_type': ExcelDataServices::Validators::TypeValidity::Types::CargoClassType,
          'currency': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'minimum': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'maximum': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'base': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'ton': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'cbm': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'kg': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'item': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'shipment': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'bill': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'container': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'wm': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'range_min': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'range_max': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'dangerous': ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType,
          'group_id': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'group_name': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
        }.freeze
      end
    end
  end
end
