# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Columns < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[columns matrixes dynamic_columns sheets].freeze

          def columns
            @columns ||= (schema_data[:columns] || []).flat_map do |column_data|
              columns_from(data: column_data)
            end
          end

          def matrixes
            @matrixes ||= (schema_data[:matrixes] || []).flat_map do |matrix_data|
              matrix_from(data: matrix_data)
            end
          end

          def dynamic_columns
            @dynamic_columns ||= (schema_data[:dynamic_columns] || []).flat_map do |dynamic_column_data|
              ExcelDataServices::V4::Files::Tables::DynamicColumns.new(
                including: dynamic_column_data[:including] || [],
                excluding: dynamic_column_data[:excluding] || [],
                header_row: dynamic_column_data[:header_row] || 1
              )
            end
          end

          def headers
            @headers ||= (columns.map(&:header) + matrixes.map(&:header)).uniq
          end

          def sheets
            @sheets ||= if schema_data[:sheets].present?
              schema_data[:sheets] & non_empty_sheets
            else
              non_empty_sheets
            end
          end

          private

          def columns_from(data:)
            expand_for_sheets(sheet_name: data[:sheet_name], exclude_sheets: data[:exclude_sheets]).map do |sheet_name|
              ExcelDataServices::V4::Files::Tables::Column.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: data[:header],
                options: ExcelDataServices::V4::Files::Tables::Options.new(options: data.except(:header))
              )
            end
          end

          def matrix_from(data:)
            expand_for_sheets(sheet_name: data[:sheet_name], exclude_sheets: data[:exclude_sheets]).map do |sheet_name|
              ExcelDataServices::V4::Files::Tables::Matrix.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: data[:header],
                rows: data[:rows],
                columns: data[:columns],
                options: ExcelDataServices::V4::Files::Tables::Options.new(options: data.except(:header))
              )
            end
          end

          def add_dynamic_columns(including: [], excluding: [])
            dynamic_columns << ExcelDataServices::V4::Files::Tables::DynamicColumns.new(including: including, excluding: excluding)
          end

          def expand_for_sheets(sheet_name:, exclude_sheets:)
            all_sheets = sheets
            all_sheets = [sheet_name] & all_sheets if sheet_name.present?
            all_sheets -= exclude_sheets if exclude_sheets.present?
            all_sheets
          end
        end
      end
    end
  end
end
