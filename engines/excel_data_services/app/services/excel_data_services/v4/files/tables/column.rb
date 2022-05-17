# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Tables
        class Column
          # A Column class is defined in the config file. It results in one column of the data frame and allows you to configure
          # santizers, fallback values, validators, required content and more
          attr_reader :header, :xlsx, :type, :sheet_name, :options

          ALPHA_INDEX = ("A".."ZZ").each.with_index(1).to_h.freeze

          ALPHA_INDEX = ("A".."ZZ").each.with_index(1).to_h.freeze

          def initialize(xlsx:, header:, sheet_name:, options: Options.new)
            @xlsx = xlsx
            @options = options
            @header = header.strip
            @sheet_name = sheet_name
          end

          def frame
            @frame ||= matrix.frame
          end

          def matrix
            @matrix ||= Matrix.new(xlsx: xlsx, header: header, rows: rows, columns: ALPHA_INDEX.key(sheet_column), sheet_name: sheet_name, options: options)
          end

          def rows
            @rows ||= [(header_row + 1), last_row].map(&:to_s).join(":")
          end

          def valid?
            errors.empty? || fallback_configured?
          end

          def present_on_sheet?
            sheet_column.present?
          end

          def errors
            @errors ||= matrix.errors
          end

          def header_row
            @header_row ||= options.header_row || (1..sheet.last_row).find { |row_nr| row_nr_is_header_row(row_nr: row_nr) } || 1
          end

          def row_nr_is_header_row(row_nr:)
            sheet.row(row_nr).any? { |value| matches_any_header?(value: value) }
          end

          def sheet_column
            @sheet_column ||= if column_index
              column_index
            else
              col = sheet.row(header_row).index { |cell_value| matches_any_header?(value: cell_value) }
              col ? col + 1 : col
            end
          end

          def matches_any_header?(value:)
            return false unless value

            ([header] | alternative_keys).include?(value.to_s.downcase.gsub(/\s/, "_"))
          end

          private

          delegate :fallback_configured?, :dynamic, :column_index, :column_length, :alternative_keys, :required, :sanitizer, :validator, to: :options

          def sheet
            xlsx.sheet(sheet_name)
          end

          def last_row
            return sheet.last_row if column_length.nil?

            header_row + column_length
          end
        end
      end
    end
  end
end
