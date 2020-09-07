# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalLocodeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass
              true
            when String
              %r{[A-Z]{2}[A-Z0-9]{3}}i.match?(value.delete(" "))
            else
              false
            end
          end
        end
      end
    end
  end
end
