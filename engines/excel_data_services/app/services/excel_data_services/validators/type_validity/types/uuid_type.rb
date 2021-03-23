# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class UuidType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
            else
              false
            end
          end
        end
      end
    end
  end
end
