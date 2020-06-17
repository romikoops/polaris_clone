# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Hubs < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'locode': :locode
        }.freeze
      end
    end
  end
end
