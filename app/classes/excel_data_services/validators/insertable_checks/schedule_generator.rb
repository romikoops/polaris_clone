# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class ScheduleGenerator < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_carrier_exists(row)
        end

        def check_carrier_exists(row)
          return if row.carrier.nil?

          if Legacy::Carrier.find_by(code: row.carrier).blank? # rubocop:disable Style/GuardClause
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "There exists no carrier called '#{row.carrier}'.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end
      end
    end
  end
end
