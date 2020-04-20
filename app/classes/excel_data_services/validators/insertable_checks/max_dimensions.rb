# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class MaxDimensions < ExcelDataServices::Validators::InsertableChecks::Base
        VALID_LOAD_TYPES = (%w[lcl] + Container::CARGO_CLASSES).freeze

        private

        def check_single_data(row)
          check_load_type(row)
        end

        def check_load_type(row)
          return if VALID_LOAD_TYPES.include?(row[:load_type])

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: 'The provided load type is invalid',
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
