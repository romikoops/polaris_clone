# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Tables
        class Sheet
          # This class encapsulates the logic for combingin the columns together to form a DataFrame that can be incoroporated in the larger DataFrame for processing later in the pipeline
          attr_reader :section, :sheet_name

          delegate :validated_columns, :columns, :xlsx, :state, :dynamic_columns, :matrixes, to: :section

          def initialize(section:, sheet_name:)
            @section = section
            @sheet_name = sheet_name
          end

          def sheet
            @sheet = xlsx.sheet(sheet_name)
          end

          def perform
            return Rover::DataFrame.new if frame_columns.empty?

            column_frame.concat(matrix_data).concat(overrides)
          end

          def matrix_data
            @matrix_data ||= sheet_matrixes.map(&:frame).inject(Rover::DataFrame.new) { |memo, matrix_data_frame| memo.concat(matrix_data_frame) }
          end

          def errors
            @errors ||= validated_columns.flat_map(&:errors) + dynamically_generated_columns.flat_map(&:errors)
          end

          def headers
            sheet_columns.map(&:header)
          end

          def sheet_columns
            @sheet_columns ||= validated_columns.select { |col| col.sheet_name == sheet_name }
          end

          private

          def sheet_matrixes
            @sheet_matrixes ||= matrixes.select { |matrix| matrix.sheet_name == sheet_name }
          end

          def overrides
            @overrides ||= Rover::DataFrame.new(
              state.overrides.data.map do |key, value|
                {
                  "value" => value,
                  "header" => key,
                  "row" => 0,
                  "column" => 0,
                  "sheet_name" => sheet_name
                }
              end
            )
          end

          def update_column_on_missing_rows(key:, replacement_value:)
            column_frame[column_frame[key].missing][key].map! { |_value| replacement_value }
          end

          def column_frame
            @column_frame ||= frame_columns.drop(1).inject(initial_column_frame) do |result, col|
              result.concat(col.frame)
            end
          end

          def frame_columns
            @frame_columns ||= columns.select { |col| col.sheet_name == sheet_name } + dynamically_generated_columns
          end

          def initial_column_frame
            frame_columns.first.frame
          end

          def dynamically_generated_columns
            @dynamically_generated_columns ||= dynamic_columns.flat_map { |dynamic_column| dynamic_column.columns(sheet: self) }
          end
        end
      end
    end
  end
end
