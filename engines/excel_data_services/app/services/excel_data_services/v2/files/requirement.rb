# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Files
      class Requirement
        # The Requirement class validates the presence of certain content in a given range of rows and columns

        attr_reader :rows, :columns, :content, :sheet_name, :xlsx

        def initialize(rows:, columns:, content:, sheet_name:, xlsx:)
          @rows = rows
          @columns = columns
          @content = content
          @sheet_name = sheet_name
          @xlsx = xlsx
        end

        def valid?
          (content - sheet_content).empty?
        end

        def sheet_content
          section_rows.product(section_cols).map { |row, col| sheet.cell(row, col) }.uniq
        end

        private

        def section_rows
          ExcelDataServices::V2::Files::Coordinates::Base.extract(
            sheet: sheet, coordinates: rows, counterpart: columns, axis: "rows"
          )
        end

        def section_cols
          ExcelDataServices::V2::Files::Coordinates::Base.extract(
            sheet: sheet, coordinates: columns, counterpart: rows, axis: "columns"
          )
        end

        def sheet
          @sheet ||= xlsx.sheet(sheet_name)
        end
      end
    end
  end
end
