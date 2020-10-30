# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Schedules < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'from': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'to': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'closing_date': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'etd': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'eta': ExcelDataServices::Validators::TypeValidity::Types::DateType,
          'transit_time': ExcelDataServices::Validators::TypeValidity::Types::OptionalIntegerLikeType,
          'service_level': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'carrier': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'mode_of_transport': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'vessel': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'voyage_code': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'load_type': ExcelDataServices::Validators::TypeValidity::Types::LoadTypeType
        }.freeze
      end
    end
  end
end
