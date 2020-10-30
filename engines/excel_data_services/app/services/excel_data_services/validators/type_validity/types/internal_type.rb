# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class InternalType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              ["X", "x", ""].include?(value)
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
