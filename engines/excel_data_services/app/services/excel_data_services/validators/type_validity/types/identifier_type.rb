# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class IdentifierType < ExcelDataServices::Validators::TypeValidity::Types::Base
          VALID_IDENTIFIERS = %w[postal_code zipcode city locode distance].freeze
          def valid?
            case value
            when String
              VALID_IDENTIFIERS.include?(value)
            else
              false
            end
          end
        end
      end
    end
  end
end
