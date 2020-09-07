# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module ValidationErrors
      class TypeValidity < ExcelDataServices::Validators::ValidationErrors::Base
        class CargoClassType < TypeValidity
        end
        class DateType < TypeValidity
        end
        class FeeType < TypeValidity
        end
        class IntegerType < TypeValidity
        end
        class LoadTypeType < TypeValidity
        end
        class NumericOrMoneyType < TypeValidity
        end
        class OptionalBooleanType < TypeValidity
        end
        class OptionalIntegerLikeType < TypeValidity
        end
        class OptionalInternalType < TypeValidity
        end
        class OptionalLocodeType < TypeValidity
        end
        class OptionalNumericType < TypeValidity
        end
        class OptionalNumericOrMoneyType < TypeValidity
        end
        class OptionalStringType < TypeValidity
        end
        class StringType < TypeValidity
        end
      end
    end
  end
end
