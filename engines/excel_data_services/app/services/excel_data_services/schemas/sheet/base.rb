# frozen_string_literal: true

# The Schemas::Sheet class defines the interaction with the specific type of sheet in question
module ExcelDataServices
  module Schemas
    module Sheet
      class Base
        attr_reader :file, :sheet_name

        def initialize(file:, sheet_name:)
          @file = file
          @sheet_name = sheet_name
        end

        def sheet
          file.sheet(sheet_name)
        end

        def valid?
          ExcelDataServices::Schemas::Validator.valid?(source: self)
        end

        def content_positions(section:)
          section_rows = section_values_by_axis(section: section, axis: "rows")
          section_cols = section_values_by_axis(section: section, axis: "cols")
          positions = section_rows.product(section_cols).map { |row, col|
            {row: row, col: col}
          }.uniq
          Rover::DataFrame.new(positions)
        end

        private

        def section_values_by_axis(section:, axis:)
          ExcelDataServices::Schemas::Coordinates::Base.extract(
            source: self, section: section, axis: axis
          )
        end
      end
    end
  end
end
