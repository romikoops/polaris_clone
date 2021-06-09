# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class StatusType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              %w[active inactive].include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
