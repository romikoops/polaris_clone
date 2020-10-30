# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
      class Location < ExcelDataServices::Validators::Extractions::Base
        def append_error(row:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :warning,
            row_nr: row["zone_row"],
            sheet_name: row["sheet_name"],
            reason: error_reason(row: row),
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def error_reason(row:)
          name = row.values_at("primary", "secondary").join(", ")
          "The location '#{name}' cannot be found."
        end

        def required_key
          "location_id"
        end
      end
    end
  end
end
