# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalCargoClassType < ExcelDataServices::Validators::TypeValidity::Types::Base
          CARGO_CLASSES = (%w[lcl fcl] + ::Legacy::Container::CARGO_CLASSES).freeze

          def valid?
            case value
            when String
              CARGO_CLASSES.include?(value.downcase)
            when NilClass
              true
            else
              false
            end
          end
        end
      end
    end
  end
end
