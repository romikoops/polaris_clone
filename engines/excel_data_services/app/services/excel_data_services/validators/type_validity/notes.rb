# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Notes < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'country': ExcelDataServices::Validators::TypeValidity::Types::StringType,
          'unlocode': ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType,
          'note': ExcelDataServices::Validators::TypeValidity::Types::StringType
        }.freeze
      end
    end
  end
end
