# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Tables
        class DynamicColumns
          # This class acts to capture the dynamic fee columns used in our fcl sheet and make sure they are in the frame.

          def initialize(including:, excluding:, header_row: 1)
            @including = including
            @excluding = excluding
            @header_row = header_row
          end

          def columns(sheet:)
            DynamicSheetColumns.new(
              sheet: sheet,
              including: including,
              excluding: excluding,
              header_row: header_row
            ).columns
          end

          private

          attr_reader :including, :excluding, :header_row

          class DynamicSheetColumns
            attr_reader :sheet, :including, :excluding, :header_row

            def initialize(sheet:, including:, excluding:, header_row: 1)
              @sheet = sheet
              @including = including
              @excluding = excluding
              @header_row = header_row
            end

            def columns
              target_headers.map do |column_index|
                DynamicSheetColumn.new(
                  xlsx: xlsx,
                  sheet_name: sheet_name,
                  column_index: column_index
                ).column
              end
            end

            delegate :xlsx, :sheet_name, to: :sheet

            def headers
              1.upto(roo_sheet.last_column).to_a - defined_columns
            end

            def header_values
              @header_values ||= roo_sheet.row(header_row).map(&:downcase)
            end

            def target_headers
              excluded = (headers - excluded_columns)
              return excluded if including.blank?

              excluded & included_columns
            end

            def roo_sheet
              @roo_sheet ||= xlsx.sheet(sheet_name)
            end

            def excluded_columns
              @excluded_columns ||= excluding.map(&:downcase)
                .map { |excluded_header| header_values.index(excluded_header) }
                .compact
                .map { |excluded_header_index| excluded_header_index + 1 }
            end

            def included_columns
              @included_columns ||= including.map(&:downcase)
                .map { |included_header| header_values.index(included_header) }
                .map { |excluded_index| excluded_index + 1 }
                .reject(&:zero?)
            end

            def defined_columns
              @defined_columns ||= sheet.sheet_columns.map(&:sheet_column)
            end
          end

          class DynamicSheetColumn
            attr_reader :sheet_name, :xlsx, :column_index

            def initialize(sheet_name:, xlsx:, column_index:)
              @sheet_name = sheet_name
              @xlsx = xlsx
              @column_index = column_index
            end

            def column
              ExcelDataServices::V3::Files::Tables::Column.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: "Dynamic:#{header.downcase.strip}",
                options: options
              )
            end

            def options
              ExcelDataServices::V3::Files::Tables::Options.new(options: {
                dynamic: true,
                alternative_keys: [header.downcase],
                sanitizer: sanitizer,
                validator: validator
              })
            end

            def header
              (xlsx.sheet(sheet_name).cell(1, column_index) || column_index).to_s.strip
            end

            def sanitizer
              case header
              when /curr_month|next_month/
                "upcase"
              when /curr_fee|next_fee/
                "money"
              else
                "text"
              end
            end

            def validator
              case header
              when /curr_month|next_month/
                "optional_month"
              when /curr_fee|next_fee/
                "optional_numeric_or_money"
              else
                "any"
              end
            end
          end
        end
      end
    end
  end
end
