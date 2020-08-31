# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module ValidationErrors
      class TypeValidity < ExcelDataServices::Validators::ValidationErrors::Base
        class InvalidDate < TypeValidity
        end

        class InvalidString < TypeValidity
        end

        class InvalidFee < TypeValidity
        end

        class InvalidOptionalLocode < TypeValidity
        end

        class InvalidOptionalString < TypeValidity
        end

        class InvalidOptionalInteger < TypeValidity
        end

        class InvalidOptionalNumeric < TypeValidity
        end

        class InvalidNumeric < TypeValidity
        end

        class InvalidOptionalBoolean < TypeValidity
        end

        class InvalidInteger < TypeValidity
        end

        class InvalidOptionalInternal < TypeValidity
        end

        class InvalidLoadType < TypeValidity
        end

        class InvalidCargoClass < TypeValidity
        end
      end
    end
  end
end
