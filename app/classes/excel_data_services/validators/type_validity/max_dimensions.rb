# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class MaxDimensions < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'origin_locode': :locode,
          'destination_locode': :locode
        }.freeze
      end
    end
  end
end
