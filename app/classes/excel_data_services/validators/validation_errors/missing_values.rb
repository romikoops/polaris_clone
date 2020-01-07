# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module ValidationErrors
      class MissingValues < ExcelDataServices::Validators::ValidationErrors::Base
        class UnknownRateBasis < MissingValues
        end

        class MissingValuesForRateBasis < MissingValues
        end

        class MissingValuesForHub < MissingValues
        end
      end
    end
  end
end
