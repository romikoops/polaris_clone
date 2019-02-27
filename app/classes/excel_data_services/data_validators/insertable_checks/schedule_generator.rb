# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class ScheduleGenerator < ExcelDataServices::DataValidators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_carrier_exists(row)
        end

        def check_carrier_exists(row)
          return if row.carrier.nil?

          if Carrier.find_by_name(row.carrier).blank? # rubocop:disable Style/GuardClause
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              reason: "There exists no carrier called '#{row.carrier}'.",
              exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks
            )
          end
        end
      end
    end
  end
end
