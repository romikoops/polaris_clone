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

        class InvalidLocode < TypeValidity
        end

        class InvalidOptionalString < TypeValidity
        end

        class InvalidInternal < TypeValidity
        end

        class InvalidLoadType < TypeValidity
        end
      end
    end
  end
end
