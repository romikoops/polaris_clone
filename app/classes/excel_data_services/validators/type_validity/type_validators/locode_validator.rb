# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class LocodeValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              String => ->(obj) { obj.delete(' ').length == 5 },
              NilClass => ->(_obj) { true }
            }
          end
        end
      end
    end
  end
end
