# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module ValidationErrors
      class MissingValues < ExcelDataServices::DataValidators::ValidationErrors::Base
        class UnknownRateBasis < MissingValues
        end

        class MissingValuesForRateBasis < MissingValues
        end
      end
    end
  end
end
