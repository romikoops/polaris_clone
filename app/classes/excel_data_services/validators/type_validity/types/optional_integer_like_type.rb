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
            else
              false
            end
          end
        end
      end
    end
  end
end
