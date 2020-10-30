# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class CurrencyType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              value.match?(/[A-Z]{3}/)
            else
              false
            end
          end
        end
      end
    end
  end
end
