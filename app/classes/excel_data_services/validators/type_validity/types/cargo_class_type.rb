# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class CargoClassType < ExcelDataServices::Validators::TypeValidity::Types::Base
          CARGO_CLASSES = (%w[lcl fcl] + Container::CARGO_CLASSES).freeze

          def valid?
            case value
            when String
              CARGO_CLASSES.include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
