# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Files
      module Tables
        class Column
          # A Column class is defined in the config file. It results in one column of the data frame and allows you to configure
          # santizers, fallback values, validators, required content and more
          attr_reader :header, :sanitizer, :validator, :required, :alternative_keys, :xlsx, :type, :sheet_name, :fallback, :dynamic

          def initialize(xlsx:, header:, sheet_name:, options: {})
            @xlsx = xlsx
            @options = options
            @header = header.strip
            @sheet_name = sheet_name
            @sanitizer = options[:sanitizer] || "text"
            @validator = options[:validator] || "string"
            @required = options[:required]
            @unique = options[:unique].present?
            @alternative_keys = options[:alternative_keys] || []
            @fallback = options[:fallback]
            @type = options[:type] || :object
            @dynamic = options[:dynamic].present?
          end

          def cells
            @cells ||= sheet_values.map.with_index do |value, index|
              ExcelDataServices::V2::Files::Tables::CellParser.new(
                column: self,
                row: index + 2,
                input: value
              )
            end
          end

          def frame
            @frame ||= Rover::DataFrame.new(
              {
                header => values.presence || nil_column,
                "row" => rows,
                "sheet_name" => [sheet_name] * rows.count
              },
              types: { header => type }
            )
          end

          def frame_type
            { header => type }
          end

          def values
            @values ||= cells.map(&:value)
          end

          def rows
            @rows ||= cells.map(&:row)
          end

          def valid?
            sheet_column.present? || fallback == false || fallback.present?
          end

          def errors
            @errors ||= [
              cells.map(&:error),
              uniqueness_constraint_error,
              required_data_missing_error
            ].flatten.compact
          end

          def sheet_values
            @sheet_values ||= sheet_column ? sheet.column(sheet_column).drop(1) : fall_back_row
          end

          def header_row
            @header_row ||= (1..sheet.last_row).find { |row_nr| row_nr_is_header_row(row_nr: row_nr) } || 1
          end

          def row_nr_is_header_row(row_nr:)
            sheet.row(row_nr).any? { |value| matches_any_header?(value: value) }
          end

          def sheet_column
            @sheet_column ||= begin
              col = sheet.row(header_row).index { |cell_value| matches_any_header?(value: cell_value) }
              col ? col + 1 : col
            end
          end

          def matches_any_header?(value:)
            return false unless value

            ([header] | alternative_keys).include?(value.to_s.downcase)
          end

          private

          def unique_constraint_satisfied?
            return true unless unique?

            sheet_values.uniq.compact.length == sheet_values.compact.length
          end

          def fall_back_row
            [fallback] * (sheet.last_row - 1)
          end

          def sheet
            xlsx.sheet(sheet_name)
          end

          def nil_column
            [nil] * rows.count
          end

          def uniqueness_constraint_error
            return if unique_constraint_satisfied?

            ExcelDataServices::V2::Files::Error.new(
              type: :type_error,
              row_nr: "",
              col_nr: sheet_column,
              sheet_name: sheet_name,
              reason: "Duplicates exists in column: #{header}. Please remove all duplicate data and try again.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::DuplicateDataFound
            )
          end

          def required_data_missing_error
            blank_cells = cells.select(&:blank?)
            return if required.blank? || (required.present? && blank_cells.empty?)

            ExcelDataServices::V2::Files::Error.new(
              type: :type_error,
              row_nr: blank_cells.map(&:row).join(", "),
              col_nr: sheet_column,
              sheet_name: sheet_name,
              reason: "Required data is missing in column: #{header}. Please fill in the missing data and try again.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::RequiredDataMissing
            )
          end

          def unique?
            @unique
          end
        end
      end
    end
  end
end
