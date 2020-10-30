# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class SacoShipping < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          '20dc': ExcelDataServices::Validators::TypeValidity::Types::FeeType,
          '40dc': ExcelDataServices::Validators::TypeValidity::Types::FeeType,
          '40hq': ExcelDataServices::Validators::TypeValidity::Types::FeeType,
          'destination_locode': ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType,
          'origin_locode': ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType,
          'effective_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'expiration_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'destination_country': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'destination_hub': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'carrier': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'terminal': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'transshipment_via': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'internal': ExcelDataServices::Validators::TypeValidity::Types::OptionalInternalType
        }.freeze
      end
    end
  end
end
