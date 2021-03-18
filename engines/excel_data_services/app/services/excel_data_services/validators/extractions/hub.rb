# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
      class Hub < ExcelDataServices::Validators::Extractions::Base
        def append_error(row:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :error,
            row_nr: 1,
            sheet_name: "",
            reason: "The hub cannot be found. Please check that the format of the sheet matches the uploader you chose",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def required_key
          "hub_id"
        end
      end
    end
  end
end
