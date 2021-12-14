# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class EmailType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              value.match?(URI::MailTo::EMAIL_REGEXP)
            else
              false
            end
          end
        end
      end
    end
  end
end
