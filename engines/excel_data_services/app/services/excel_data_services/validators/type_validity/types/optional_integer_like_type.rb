# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalIntegerLikeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass, Integer
              true
            when Float
              value % 1 == 0
            when String
              value.match(/\d/) && !value.match(/\D/)
            else
              false
            end
          end
        end
      end
    end
  end
end
