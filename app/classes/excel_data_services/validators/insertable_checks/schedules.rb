# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Schedules < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          carrier = check_carrier_exists(row)
          check_service_level_exists(row, carrier)
          check_dates_are_valid(row)
        end

        def check_dates_are_valid(row)
          return if Range.new(row.closing_date, row.eta).cover?(row.etd) # rubocop:disable Style/GuardClause

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "The dates provided are not in chronological order.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_carrier_exists(row)
          return if row.carrier.blank?

          carrier = Legacy::Carrier.find_by(code: row.carrier.downcase)

          if carrier.blank?# rubocop:disable Style/GuardClause
            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: "There exists no carrier called '#{row.carrier}'.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end

          carrier
        end

        def check_service_level_exists(row, carrier)
          tenant_vehicle = TenantVehicle.find_by(name: row.service_level, carrier: carrier, organization_id: @organization.id)
          if tenant_vehicle.blank? # rubocop:disable Style/GuardClause
            error_string = "There exists no service level called '#{row.service_level}'"
            error_string += row.carrier.present? ? " for carrier '#{row.carrier}'" : "."

            add_to_errors(
              type: :error,
              row_nr: row.nr,
              sheet_name: sheet_name,
              reason: error_string,
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end
      end
    end
  end
end
