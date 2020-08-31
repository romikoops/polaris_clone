# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class OptionalInternalValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              String => ->(obj) { ['X', 'x', ''].include?(obj) },
              NilClass => ->(_obj) { true }
            }
          end
        end
      end
    end
  end
end
