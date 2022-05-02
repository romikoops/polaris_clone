# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Tables
        class Matrix
          # A Column class is defined in the config file. It results in one column of the data frame and allows you to configure
          # santizers, fallback values, validators, required content and more
          attr_reader :header, :coordinates, :xlsx, :sheet_name, :options

          def initialize(xlsx:, rows:, columns:, header:, sheet_name:, options: Options.new)
            @xlsx = xlsx
            @options = options
            @header = header
            @sheet_name = sheet_name
            @coordinates = ExcelDataServices::V4::Files::Coordinates::Parser.new(sheet: sheet, input_rows: rows, input_columns: columns)
          end
          delegate :rows, :columns, to: :coordinates
          delegate :sanitizer, :validator, :required, :alternative_keys, :fallback, :type, :dynamic, to: :options

          def cells
            @cells ||= coordinate_values.map.with_index do |input, index|
              row, col = coordinate_pairs[index]
              ExcelDataServices::V4::Files::Tables::CellParser.new(
                container: self,
                column: col,
                row: row,
                input: input
              )
            end
          end

          def frame
            @frame ||= Rover::DataFrame.new(
              cell_frame_data, types: frame_types
            )
          end

          def coordinate_pairs
            @coordinate_pairs ||= rows.product(columns)
          end

          def cell_frame_data
            @cell_frame_data ||= cells.map do |cell|
              {
                "value" => cell.value,
                "header" => header,
                "row" => cell.row,
                "column" => cell.column,
                "sheet_name" => cell.sheet_name
              }
            end
          end

          def frame_types
            {
              "value" => type,
              "column" => :object,
              "row" => :object,
              "header" => :object,
              "sheet_name" => :object
            }
          end

          def valid?
            errors.empty?
          end

          def errors
            @errors ||= [
              options.errors,
              cells.map(&:error),
              uniqueness_constraint_error,
              required_data_missing_error
            ].flatten.compact
          end

          alias present_on_sheet? valid?

          private

          def sheet
            xlsx.sheet(sheet_name)
          end

          def uniqueness_constraint_error
            return unless unique?

            duplicate_groupings = cells.reject(&:blank?).group_by(&:value).values.reject { |cell_grouping| cell_grouping.length == 1 }
            return if duplicate_groupings.empty?

            duplicate_groupings.map do |duplicates|
              error_locations = duplicates.map(&:location).join(" & ")
              ExcelDataServices::V4::Files::Error.new(
                type: :type_error,
                row_nr: duplicates.first.row,
                col_nr: duplicates.first.column,
                sheet_name: sheet_name,
                reason: "Duplicates exists at #{error_locations}. Please remove all duplicate data and try again.",
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::DuplicateDataFound
              )
            end
          end

          def required_data_missing_error
            blank_cells = cells.select(&:blank?)
            return if required.blank? || (required.present? && blank_cells.empty?)

            blank_cells.map do |blank_cell|
              ExcelDataServices::V4::Files::Error.new(
                type: :type_error,
                row_nr: blank_cell.row,
                col_nr: blank_cell.column,
                sheet_name: sheet_name,
                reason: "Required data is missing at: #{blank_cell.location}. Please fill in the missing data and try again.",
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::RequiredDataMissing
              )
            end
          end

          def unique?
            options.unique
          end

          def coordinate_values
            @coordinate_values ||= sheet.matrix(coordinate_pairs)
          end
        end
      end
    end
  end
end
