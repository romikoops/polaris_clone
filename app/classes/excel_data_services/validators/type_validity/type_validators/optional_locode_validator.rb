# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class OptionalLocodeValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              String => ->(obj) { %r{[A-Z]{2} ?[A-Z0-9]{3}}i.match?(obj.delete(' ')) },
              NilClass => ->(_obj) { true },
              Integer => ->(_obj) { false },
              Float => ->(_obj) { false }
            }
          end
        end
      end
    end
  end
end
