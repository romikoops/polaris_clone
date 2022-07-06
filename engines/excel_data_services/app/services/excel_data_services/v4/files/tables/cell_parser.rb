# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Tables
        class CellParser
          # A cell represents each piece of data in a Column (analagous to the cell on the sheet) but with the Sanitization and TypeValidation done here so the data put into the frame is correct from the beginning.

          attr_reader :container, :input, :row, :column

          delegate :blank?, to: :value
          delegate :header, :sheet_name, :fallback, to: :container

          def initialize(container:, input:, row:, column:)
            @container = container
            @input = input
            @row = row
            @column = column
          end

          def value
            @value ||= if sanitized_value.nil?
              fallback
            else
              sanitized_value
            end
          end

          def error
            @error ||= validator_error unless valid?
          end

          def location
            [
              sheet_name && "(Sheet: #{sheet_name})",
              row && "row: #{row}",
              column && "column: #{column}"
            ].compact.join(" ")
          end

          private

          def sanitized_value
            @sanitized_value ||= sanitizer_klass.sanitize(value: input)
          end

          def sanitizer_klass
            "ExcelDataServices::V4::Sanitizers::#{container.sanitizer.camelize}".constantize
          end

          def valid?
            validator.new(value).valid?
          end

          def validator_error
            ExcelDataServices::V4::Files::Error.new(
              type: :type_error,
              row_nr: row,
              col_nr: column,
              sheet_name: sheet_name,
              reason: "The value: #{value} of the key: #{header} is not a valid #{validator_type}.",
              exception_class: exception_from_type
            )
          end

          def validator_type
            container.validator.camelize || "Any"
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
