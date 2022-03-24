# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Parsers
        class Columns < ExcelDataServices::V3::Files::Parsers::Base
          SPLIT_PATTERN = /^((column)|(matrix)|(add_dynamic_columns)|(\s+sanitizer)|(\s+validator)|(\s+required)|(\s+unique)|(\s+alternative_keys)|(\s+fallback)|(\s+type)|(\s+dynamic)|(\s+header_row)|(\s+column_length)|(\s+column_index)|(\s+fallback)|(\s+rows)|(\s+columns)|(\s+exclude_sheets)|(\s+sheet_name))/.freeze

          def columns
            @columns ||= []
          end

          def matrixes
            @matrixes ||= []
          end

          def dynamic_columns
            @dynamic_columns ||= []
          end

          def headers
            @headers ||= (columns.map(&:header) + matrixes.map(&:header)).uniq
          end

          private

          def column(header, options = {})
            @columns = expand_for_sheets(sheet_name: options[:sheet_name], exclude_sheets: options[:exclude_sheets]).inject(columns) do |existing_columns, sheet_name|
              new_column = ExcelDataServices::V3::Files::Tables::Column.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: header,
                options: ExcelDataServices::V3::Files::Tables::Options.new(options: options)
              )
              merge_item_into_collection(collection: existing_columns, item: new_column)
            end
          end

          def matrix(header, options = {})
            @matrixes = expand_for_sheets(sheet_name: options[:sheet_name], exclude_sheets: options[:exclude_sheets]).inject(matrixes) do |existing_matrixes, sheet_name|
              new_matrix = ExcelDataServices::V3::Files::Tables::Matrix.new(
                xlsx: xlsx,
                sheet_name: sheet_name,
                header: header,
                rows: options[:rows],
                columns: options[:columns],
                options: ExcelDataServices::V3::Files::Tables::Options.new(options: options)
              )
              merge_item_into_collection(collection: existing_matrixes, item: new_matrix)
            end
          end

          def merge_item_into_collection(collection:, item:)
            collection.reject { |col_item| col_item.header == item.header && col_item.sheet_name == item.sheet_name }.push(item)
          end

          def add_dynamic_columns(including: [], excluding: [])
            dynamic_columns << ExcelDataServices::V3::Files::Tables::DynamicColumns.new(including: including, excluding: excluding)
          end

          def expand_for_sheets(sheet_name:, exclude_sheets:)
            all_sheets = non_empty_sheets
            all_sheets = [sheet_name] & all_sheets if sheet_name.present?
            all_sheets -= exclude_sheets if exclude_sheets.present?
            all_sheets
          end
        end
      end
    end
  end
end
