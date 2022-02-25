# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalDateType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when Date, NilClass
              true
            when String
              date_breakdown = value.scan(/\d+/).map(&:to_i)
              return false unless date_breakdown.count.between?(3, 4) && date_breakdown.first.digits.count == 4

              Date.valid_date?(*date_breakdown)
            else
              false
            end
          end
        end
      end
    end
  end
end
