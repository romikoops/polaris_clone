# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class FeeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass
              true
            when String
              ["n/a", "incl", " ", "-"].include?(value)
            when Money
              value.amount.positive?
            else
              false
            end
          end
        end
      end
    end
  end
end
