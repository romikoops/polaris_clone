# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
      class MandatoryCharge < ExcelDataServices::Validators::Extractions::Base
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
          configuration = row.slice("import_charges", "export_charges", "pre_carriage", "on_carriage").map { |key, value| "#{key}: #{value}" }.join(", ")
          "The MandatoryCharge configuration '#{configuration}' cannot be found."
        end

        def required_key
          "mandatory_charge_id"
        end
      end
    end
  end
end
