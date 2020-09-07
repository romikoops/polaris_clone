# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Hubs < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'locode': ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType,
          'terminal': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType,
          'terminal_code': ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType
        }.freeze
      end
    end
  end
end
