# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalNumericLikeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass, Integer
              true
            when Float
              !value.nan?
            when String
              value.match(/\A-?(?:\d+(?:\.\d*)?|\.\d+)/)
            else
              false
            end
          end
        end
      end
    end
  end
end
