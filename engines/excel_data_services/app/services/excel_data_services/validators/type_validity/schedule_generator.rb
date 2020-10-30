# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class ScheduleGenerator < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'origin': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'destination': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'carrier': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'service_level': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'etd_days': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'mot': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'transit_time': ExcelDataServices::Validators::TypeValidity::Types::OptionalIntegerLikeType,
          'cargo_class': ExcelDataServices::Validators::TypeValidity::Types::LoadTypeType
        }.freeze
      end
    end
  end
end
