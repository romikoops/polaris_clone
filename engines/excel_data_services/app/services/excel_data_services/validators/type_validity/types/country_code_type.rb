# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class CountryCodeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              value.match(/[A-Z]{2}/)
            else
              false
            end
          end
        end
      end
    end
  end
end
