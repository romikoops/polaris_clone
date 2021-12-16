# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module MissingValues
      class Pricing < ExcelDataServices::Validators::MissingValues::Base
        private

        def check_single_data(row)
          check_range_values(row: row)
        end

        def check_range_values(row:)
          return if row.rate_basis.include?("_RANGE") && row.range.present? && row.range.all?(&:present?)

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "When the rate basis includes \"_RANGE\", there must be a value provided in the RANGE_MIN and RANGE_MAX column",
            exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRange
          )
        end
      end
    end
  end
end
