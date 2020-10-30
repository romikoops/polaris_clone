# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalBooleanType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass, TrueClass, FalseClass
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
