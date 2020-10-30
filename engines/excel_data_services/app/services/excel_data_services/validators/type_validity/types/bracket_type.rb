# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class BracketType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              /[0-9]{1,}-[0-9]{1,}/i.match?(value.delete(" "))
            when Integer, Float, NilClass
              false
            end
          end
        end
      end
    end
  end
end
