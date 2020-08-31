# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class LoadTypeValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              String => ->(obj) { %w[cargo_item container].include?(obj.downcase) }
            }
          end
        end
      end
    end
  end
end
