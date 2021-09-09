# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Files
      module Tables
        class Column
          # A Column class is defined in the config file. It results in one column of the data frame and allows you to configure
          # santizers, fallback values, validators, required content and more
          attr_reader :header, :sanitizer, :validator, :required, :alternative_keys, :xlsx, :type, :sheet_name, :fallback, :unique, :dynamic

          def initialize(xlsx:, header:, sheet_name:, options: {})
            @xlsx = xlsx
            @options = options
            @header = header
            @sheet_name = sheet_name
            @sanitizer = options[:sanitizer] || "text"
            @validator = options[:validator] || "string"
            @required = options[:required]
            @unique = options[:unique]
            @alternative_keys = options[:alternative_keys] || []
            @fallback = options[:fallback]
            @type = options[:type] || :object
            @dynamic = options[:dynamic].present?
          end

          def cells
            @cells ||= sheet_values.map.with_index do |value, index|
              ExcelDataServices::V2::Files::Tables::CellParser.new(
                column: self,
                row: index + 1,
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
            errors.compact.empty? && (required.blank? || (required.present? && cells.none?(&:blank?))) && unique_constraint_satisfied?
          end

          def errors
            @errors ||= cells.map(&:error).compact
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

          def unique_constraint_satisfied?
            return true unless @unique

            sheet_values.uniq.length == sheet_values.length
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
        end
      end
    end
  end
end
