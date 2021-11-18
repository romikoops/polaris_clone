# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Operations
      module Dynamic
        class FeeFromColumns
          def initialize(columns:)
            @columns = columns
            @fee_code = columns.first.fee_code
          end

          def frame
            return columns.first.data if columns.length == 1

            column_frame[!column_frame["effective_date"].missing]
          end

          private

          attr_reader :fee_code, :columns

          def column_frame
            @column_frame ||= fee_columns.inject(base_frame) do |new_frame, column|
              new_frame.concat(data_from_column(column: column))
            end
          end

          def data_from_column(column:)
            column_data = column.data
            return column_data if period_column.blank?

            column_data[column_data.keys - %w[effective_date expiration_date]]
              .left_join(period_column.data, on: { "row" => "row", "sheet_name" => "sheet_name" })
          end

          def period_column
            @period_column ||= columns.find { |col| col.category == :month }
          end

          def fee_columns
            @fee_columns ||= columns - [period_column]
          end

          def base_frame
            Rover::DataFrame.new({ "rate" => [] }, types: { "rate" => :object })
          end
        end
      end
    end
  end
end
