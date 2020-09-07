# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalInternalType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass
              true
            when String
              ["X", "x", ""].include?(value)
            else
              false
            end
          end
        end
      end
    end
  end
end
