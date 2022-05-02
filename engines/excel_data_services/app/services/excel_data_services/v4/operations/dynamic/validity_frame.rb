# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      module Dynamic
        class ValidityFrame
          def initialize(date_frame:, columns:)
            @date_frame = date_frame
            @columns = columns
          end

          attr_reader :date_frame, :columns

          def frame
            date_frame.to_a.each_with_object(Rover::DataFrame.new) do |row, inner_frame|
              dates_for_row = combined_date_frame[(combined_date_frame["row"] == row["row"]) & (combined_date_frame["sheet_name"] == row["sheet_name"])]
              inner_frame.concat(ExpandedDatesFrame.new(row: row, row_frame: dates_for_row).frame)
            end
          end

          def combined_date_frame
            @combined_date_frame ||= date_frame.concat(month_column_frame)
          end

          def month_column_frame
            @month_column_frame ||= columns.each_with_object(Rover::DataFrame.new) { |col, new_frame| new_frame.concat(col.data) }
          end
        end
      end
    end
  end
end
