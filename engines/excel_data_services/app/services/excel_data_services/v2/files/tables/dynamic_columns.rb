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
            DynamicColumnSheet.new(
              sheet: sheet,
              including: including,
              excluding: excluding,
              header_row: header_row
            ).columns
          end

          private

          attr_reader :including, :excluding, :header_row

          class DynamicColumnSheet
            attr_reader :sheet, :including, :excluding, :header_row

            def initialize(sheet:, including:, excluding:, header_row: 1)
              @sheet = sheet
              @including = including
              @excluding = excluding
              @header_row = header_row
            end

            def columns
              target_headers.map do |header|
                ExcelDataServices::V2::Files::Tables::Column.new(
                  xlsx: xlsx,
                  sheet_name: sheet_name,
                  header: header.downcase,
                  options: { dynamic: true }
                )
              end
            end

            delegate :xlsx, :sheet_name, to: :sheet

            def headers
              header_values.reject { |value| sheet.columns.any? { |col| col.matches_any_header?(value: value) } }
            end

            def header_values
              xlsx.sheet(sheet_name).row(header_row).map(&:downcase)
            end

            def target_headers
              excluded = (headers - excluding.map(&:downcase))
              return excluded if including.blank?

              excluded & including
            end
          end
        end
      end
    end
  end
end
