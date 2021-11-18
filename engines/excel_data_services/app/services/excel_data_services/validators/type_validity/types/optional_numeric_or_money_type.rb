# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalNumericOrMoneyType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when NilClass, Integer, Float, Money
              true
            when String
              %w[incl n/a].include?(value.downcase.strip)
            else
              false
            end
          end
        end
      end
    end
  end
end
