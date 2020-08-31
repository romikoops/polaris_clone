# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class CargoClassValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          CARGO_CLASSES = (%w[lcl fcl] + Container::CARGO_CLASSES).freeze
          def valid_types_with_values
            {
              String => ->(obj) { CARGO_CLASSES.include?(obj.downcase) }
            }
          end
        end
      end
    end
  end
end
