# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class FeeValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              String => ->(obj) { ['n/a', 'incl'].include?(obj) },
              Money => ->(obj) { obj.amount.positive? }
            }
          end
        end
      end
    end
  end
end
