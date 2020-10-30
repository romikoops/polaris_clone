# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class NumericType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when Float, Integer, BigDecimal
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
