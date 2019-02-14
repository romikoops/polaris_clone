# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module ValidationError
      class Format < Base
        class InvalidHeaders < Format
        end

        class UnknownRateBasis < Format
        end

        class MissingValuesForRateBasis < Format
        end
      end
    end
  end
end
