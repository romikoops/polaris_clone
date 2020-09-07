# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class StringType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
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
