# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class BooleanType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              ["t", "true", "f", "false"].include?(value.downcase)
            when Integer
              [0, 1].include?(value)
            when Float, NilClass
              false
            when TrueClass, FalseClass
              true
            end
          end
        end
      end
    end
  end
end
