# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class ModifierType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              Trucking::Trucking::MODIFIERS.include?(value)
            else
              false
            end
          end
        end
      end
    end
  end
end
