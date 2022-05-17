# frozen_string_literal: true

module ExcelDataServices
  module V4
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
              @including = including.map(&:downcase)
              @excluding = excluding.map(&:downcase)
              @header_row = header_row
            end

            def columns
              target_headers_with_column.map do |header_with_column|
                DynamicSheetColumn.new(
                  xlsx: xlsx,
                  sheet_name: sheet_name,
                  header: header_with_column[:value],
                  column_index: header_with_column[:column]
                ).column
              end
            end

            delegate :xlsx, :sheet_name, to: :sheet

            def unassigned_headers
              header_values_with_index.reject do |value_and_column|
                !value_and_column[:value] || sheet.columns.any? { |col| col.matches_any_header?(value: value_and_column[:value]) }
              end
            end

            def header_values_with_index
              xlsx.sheet(sheet_name).row(header_row).map.with_index do |value, index|
                value = value.downcase if value
                { value: value, column: index + 1 }
              end
            end

            def target_headers_with_column
              return post_exclusion_headers if including.blank?

              post_inclusion_headers
            end

            def post_exclusion_headers
              unassigned_headers.reject do |unassigned_header|
                excluding.include?(unassigned_header[:value])
              end
            end

            def post_inclusion_headers
              unassigned_headers.select do |unassigned_header|
                including.include?(unassigned_header[:value])
              end
            end
          end

          class DynamicSheetColumn
            attr_reader :sheet_name, :xlsx, :header, :column_index

            def initialize(sheet_name:, xlsx:, header:, column_index:)
              @sheet_name = sheet_name
              @xlsx = xlsx
              @header = header.downcase
              @column_index = column_index
            end

            def column
              @column ||= ExcelDataServices::V4::Files::Tables::Column.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: "Dynamic(#{sheet_name}-#{column_index}):#{snake_case_header}",
                options: options
              )
            end

            def options
              ExcelDataServices::V4::Files::Tables::Options.new(options: {
                dynamic: true,
                alternative_keys: [header.downcase],
                sanitizer: sanitizer,
                validator: validator,
                column_index: column_index
              })
            end

            def snake_case_header
              header.strip.downcase.gsub(/\s/, "_")
            end

            def sanitizer
              case header
              when /_month/
                "upcase"
              when /_fee/
                "money"
              else
                "text"
              end
            end

            def validator
              case header
              when /_month/
                "optional_month"
              when /_fee/
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
