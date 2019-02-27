# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module ValidationErrors
      class WritingError < ExcelDataServices::DataValidators::ValidationErrors::Base
        class UnknownSheetNameError < WritingError
        end

        class PerUnitTonCbmRangeError < WritingError
        end

        class UnknownRateBasisError < WritingError
        end
      end
    end
  end
end
