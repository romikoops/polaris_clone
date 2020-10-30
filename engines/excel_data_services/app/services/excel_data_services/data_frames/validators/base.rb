# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Validators
      class Base < ExcelDataServices::DataFrames::Base
        def perform
          filtered_schema_validators.each do |key, type_validator|
            frame.to_a.each do |row|
              next if type_validator.new(row[key]).valid?

              type = type_validator.name.demodulize
              append_error(error_cell: row, key: key, type: type, sheet_name: row["sheet_name"])
            end
          end

          @state
        end

        private

        attr_reader :value

        def append_error(error_cell:, key:, type:, sheet_name:)
          @state.errors << ExcelDataServices::DataFrames::Validators::Error.new(
            type: :type_error,
            row_nr: error_cell["#{key}_row"],
            col_nr: error_cell["#{key}_col"],
            sheet_name: error_cell[sheet_name],
            reason: "The value: #{error_cell[key]} of the key: #{key} is not a valid #{type}.",
            exception_class: exception_from_type(type: type)
          )
        end

        def exception_from_type(type:)
          ExcelDataServices::Validators::ValidationErrors::TypeValidity.const_get(type)
        end

        def filtered_schema_validators
          schema_validator_lookup.slice(*frame.keys)
        end
      end
    end
  end
end
