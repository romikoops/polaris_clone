# frozen_string_literal: true

module ExcelDataServices
  module V2
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
              target_headers.map do |header|
                DynamicSheetColumn.new(
                  xlsx: xlsx,
                  sheet_name: sheet_name,
                  header: header
                ).column
              end
            end

            delegate :xlsx, :sheet_name, to: :sheet

            def headers
              header_values.reject { |value| sheet.columns.any? { |col| col.matches_any_header?(value: value) } }
            end

            def header_values
              xlsx.sheet(sheet_name).row(header_row).compact.map(&:downcase)
            end

            def target_headers
              excluded = (headers - excluding.map(&:downcase))
              return excluded if including.blank?

              excluded & including
            end
          end

          class DynamicSheetColumn
            attr_reader :sheet_name, :xlsx, :header

            def initialize(sheet_name:, xlsx:, header:)
              @sheet_name = sheet_name
              @xlsx = xlsx
              @header = header.downcase
            end

            def column
              ExcelDataServices::V2::Files::Tables::Column.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: "Dynamic:#{header.strip}",
                options: options
              )
            end

            def options
              {
                dynamic: true,
                alternative_keys: [header.downcase],
                sanitizer: sanitizer,
                validator: validator
              }
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
