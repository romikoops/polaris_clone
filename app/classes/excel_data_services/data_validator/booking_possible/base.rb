# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module BookingPossible
      class Base
        include ExcelDataServices::DataValidator

        BookingPossibleError = Class.new(ValidationError)

        def perform
        end
      end
    end
  end
end
