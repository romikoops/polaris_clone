# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module ValidationErrors
      class WritingError < ExcelDataServices::Validators::ValidationErrors::Base
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
