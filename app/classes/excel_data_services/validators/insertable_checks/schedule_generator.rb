# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class ScheduleGenerator < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_carrier_and_tenant_vehicle_exists(row)
          check_itinerary_exists(row)
        end

        def check_carrier_and_tenant_vehicle_exists(row)
          carrier_name = row.carrier
          service_level = row.service_level
          return if carrier_name.nil? && service_level.nil?

          carrier = Legacy::Carrier.find_by(code: carrier_name.downcase)
          check_tenant_vehicle_exists(row, carrier)
          return if carrier.present?

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "There exists no carrier called '#{carrier_name}'.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_tenant_vehicle_exists(row, carrier)
          service_level = row.service_level
          return if service_level.nil?

          return if Legacy::TenantVehicle.exists?(name: service_level, carrier_id: carrier&.id)

          reason = "There exists no service called '#{service_level}'"
          reason += " for carrier '#{carrier.name}'" if carrier.present?
          reason += "."
          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: reason,
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def check_itinerary_exists(row)
          itinerary_name = row.itinerary_name
          return if Legacy::Itinerary.where("name ILIKE ?", itinerary_name)
            .exists?(organization: organization, mode_of_transport: row.mode_of_transport)

          add_to_errors(
            type: :error,
            row_nr: row.nr,
            sheet_name: sheet_name,
            reason: "There exists no itinerary called '#{itinerary_name}'.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
