# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module MissingValues
      class Schedules < ExcelDataServices::Validators::MissingValues::Base
        private

        def check_single_data(row)
          check_row_requirements(row)
        end

        def check_row_requirements(row)
          %i[eta etd closing_date service_level mode_of_transport from to load_type].each do |row_key|
            next if row[row_key].present?

            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "Missing value for #{row_key.upcase}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues
            )
          end
        end
      end
    end
  end
end
