# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class RateBasisType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              value.delete(" ").match?(/PER/)
            else
              false
            end
          end
        end
      end
    end
  end
end
