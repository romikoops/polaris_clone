# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class OptionalNumericValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              Float => ->(_obj) { true },
              Integer => ->(_obj) { true },
              NilClass => ->(_obj) { true }
            }
          end
        end
      end
    end
  end
end
