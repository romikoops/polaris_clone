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
            when Integer
              [0, 1].include?(value)
            when String
              %w[t true f false].include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
