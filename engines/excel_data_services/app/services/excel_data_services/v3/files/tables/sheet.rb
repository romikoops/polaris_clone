# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Tables
        class Sheet
          # This class encapsulates the logic for combingin the columns together to form a DataFrame that can be incoroporated in the larger DataFrame for processing later in the pipeline
          attr_reader :section, :sheet_name

          delegate :validated_columns, :columns, :xlsx, :state, :dynamic_columns, to: :section

          def initialize(section:, sheet_name:)
            @section = section
            @sheet_name = sheet_name
          end

          def sheet
            @sheet = xlsx.sheet(sheet_name)
          end

          def perform
            add_override_columns
            return Rover::DataFrame.new if frame_columns.empty?

            column_frame
          end

          def errors
            @errors ||= validated_columns.flat_map(&:errors) + dynamically_generated_columns.flat_map(&:errors)
          end

          def headers
            sheet_columns.map(&:header)
          end

          private

          def sheet_columns
            @sheet_columns ||= validated_columns.select { |col| col.sheet_name == sheet_name }
          end

          def add_override_columns
            state.overrides.data.each do |key, value|
              column_frame[key] = [value] * column_frame.count unless column_frame.include?(key)
            end
          end

          def update_column_on_missing_rows(key:, replacement_value:)
            column_frame[column_frame[key].missing][key].map! { |_value| replacement_value }
          end

          def column_frame
            @column_frame ||= frame_columns.drop(1).inject(initial_column_frame) do |result, col|
              result.left_join(col.frame, on: { "row" => "row", "sheet_name" => "sheet_name" })
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
