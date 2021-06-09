# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
      class Address < ExcelDataServices::Validators::Extractions::Base
        def append_error(row:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :warning,
            row_nr: row["zone_row"],
            sheet_name: row["sheet_name"],
            reason: "The address '#{row['full_address']} (Lat: #{row['latitude']}, Lon: #{row['longitude']})' cannot be found.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def required_key
          "address_id"
        end
      end
    end
  end
end
