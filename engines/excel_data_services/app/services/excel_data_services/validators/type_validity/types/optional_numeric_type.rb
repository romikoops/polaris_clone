# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalNumericType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass, Integer, Float, BigDecimal
              true
            else
              false
            end
          end
        end
      end
    end
  end
end
