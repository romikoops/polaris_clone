# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class LoadTypeValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          LOAD_TYPES = (%w[lcl fcl] + Container::CARGO_CLASSES).freeze
          def valid_types_with_values
            {
              String => ->(obj) { LOAD_TYPES.include?(obj.downcase) }
            }
          end
        end
      end
    end
  end
end
