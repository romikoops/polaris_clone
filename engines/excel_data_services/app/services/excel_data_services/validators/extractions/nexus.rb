# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
      class Nexus < ExcelDataServices::Validators::Extractions::Base
        def append_error(row:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :warning,
            row_nr: row["zone_row"],
            sheet_name: row["sheet_name"],
            reason: "The nexus '#{row['name']} (#{row['locode']})' cannot be found.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def required_key
          "nexus_id"
        end
      end
    end
  end
end
