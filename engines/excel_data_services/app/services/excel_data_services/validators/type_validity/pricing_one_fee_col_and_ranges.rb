# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class PricingOneFeeColAndRanges < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'expiration_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'origin_locode': ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType,
          'destination_locode': ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType,
          'load_type': ExcelDataServices::Validators::TypeValidity::Types::CargoClassType,
          'transshipment': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'origin': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'country_origin': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'destination': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'country_destination': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'mot': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'carrier': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'service_level': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'rate_basis': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'range_min': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'range_max': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType,
          'fee_code': ExcelDataServices::Validators::TypeValidity::Types::AnyType,
          'fee_name': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'currency': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'fee_min': ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericOrMoneyType,
          'fee': ExcelDataServices::Validators::TypeValidity::Types::NumericOrMoneyType,
          'group_id': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'group_name': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'transit_time': ExcelDataServices::Validators::TypeValidity::Types::OptionalIntegerLikeType,
          'remarks': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'wm_ratio': ExcelDataServices::Validators::TypeValidity::Types::OptionalIntegerLikeType
        }.freeze
      end
    end
  end
end
