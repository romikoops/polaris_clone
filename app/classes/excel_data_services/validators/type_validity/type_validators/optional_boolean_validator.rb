# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class OptionalBooleanValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              TrueClass => ->(_obj) { true },
              FalseClass => ->(_obj) { true },
              NilClass => ->(_obj) { true }
            }
          end
        end
      end
    end
  end
end
