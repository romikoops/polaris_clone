# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class RowValidation
        # This class takes an array of keys and runs comparisons on them to determine validity. Useful for preventing invalid data passing through individual checks

        attr_reader :keys, :comparator, :message

        def initialize(keys:, comparator:, message: nil)
          @keys = keys
          @comparator = comparator
          @message = message
        end

        def state(state:)
          state.frame[error_keys].each_row do |row|
            validator_row = Row.new(row: row, keys: keys, comparator: comparator, message: message)
            state.errors << validator_row.error unless validator_row.valid?
          end
          state
        end

        def error_keys
          [*keys, "row", "sheet_name"]
        end

        class Row
          # Inner class for Row comparison and error generation
          def initialize(row:, comparator:, keys:, message:)
            @row = row
            @comparator = comparator
            @keys = keys
            @message = message
          end

          def valid?
            comparator.call(row.values_at(*keys))
          end

          def error
            ExcelDataServices::V4::Files::Error.new(
              type: :warning,
              row_nr: row["row"],
              sheet_name: row["sheet_name"],
              reason: error_reason,
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end

          private

          attr_reader :row, :keys, :comparator, :message

          def error_reason
            message || "The values in columns #{keys.join(',')} in row #{row['row']} on sheet #{row['sheet_name']} are invalid - please check them before reuploading."
          end
        end
      end
    end
  end
end
