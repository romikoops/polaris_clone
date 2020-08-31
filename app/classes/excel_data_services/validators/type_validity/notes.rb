# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Notes < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'country': :string,
          'unlocode': :locode,
          'note': :string
        }.freeze
      end
    end
  end
end
