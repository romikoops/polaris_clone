# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class DateValidator < ExcelDataServices::Validators::TypeValidity::TypeValidators::Base
          def valid_types_with_values
            {
              Date => ->(_obj) { true },
              String => ->(obj) {
                date_breakdown = obj.scan(/\d+/).map(&:to_i)
                return false unless date_breakdown.count.between?(3, 4) && date_breakdown.first.digits.count == 4

                Date.valid_date?(*date_breakdown)
              }
            }
          end
        end
      end
    end
  end
end
