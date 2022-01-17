# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Tables
        class CellParser
          # A cell represents each piece of data in a Column (analagous to the cell on the sheet) but with the Sanitization and TypeValidation done here so the data put into the frame is correct from the beginning.

          attr_reader :column, :input, :row

          delegate :blank?, to: :input
          delegate :header, :sheet_name, :fallback, :sheet_column, to: :column

          def initialize(column:, input:, row:)
            @column = column
            @input = input
            @row = row
          end

          def value
            @value ||= if matches_any_header?
              input
            elsif sanitized_value.nil?
              fallback
            else
              sanitized_value
            end
          end

          def error
            @error ||= validator_error unless valid?
          end

          private

          def sanitized_value
            @sanitized_value ||= sanitizer_klass.sanitize(value: input)
          end

          def sanitizer_klass
            "ExcelDataServices::V3::Sanitizers::#{column.sanitizer.camelize}".constantize
          end

          def matches_any_header?
            column.matches_any_header?(value: input)
          end

          def valid?
            validator.new(value).valid?
          end

          def validator_error
            ExcelDataServices::V3::Files::Error.new(
              type: :type_error,
              row_nr: row,
              col_nr: sheet_column,
              sheet_name: sheet_name,
              reason: "The value: #{value} of the key: #{header} is not a valid #{validator_type}.",
              exception_class: exception_from_type
            )
          end

          def validator_type
            column.validator.camelize || "Any"
          end

          def exception_from_type
            ExcelDataServices::Validators::ValidationErrors::TypeValidity.const_get("#{validator_type}Type")
          end

          def validator
            "ExcelDataServices::Validators::TypeValidity::Types::#{validator_type}Type".constantize
          end
        end
      end
    end
  end
end
