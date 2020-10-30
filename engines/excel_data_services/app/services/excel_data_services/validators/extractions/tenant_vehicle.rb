# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
      class TenantVehicle < ExcelDataServices::Validators::Extractions::Base
        def append_error(row:)
          carrier_string = row["carrier"].present? && " on carrier '#{row["carrier"]}'"
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :error,
            row_nr: row["service_row"],
            sheet_name: row["sheet_name"],
            reason: "The service '#{row["service"]}'#{carrier_string} cannot be found.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def required_key
          "tenant_vehicle_id"
        end
      end
    end
  end
end
