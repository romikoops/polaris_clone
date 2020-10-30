# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalNumericOrMoneyType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass, Integer, Float, Money
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
