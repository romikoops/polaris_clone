# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Tables
        class Sheet
          # This class encapsulates the logic for combingin the columns together to form a DataFrame that can be incoroporated in the larger DataFrame for processing later in the pipeline
          attr_reader :section_parser, :sheet_name, :state

          delegate :columns, :dynamic_columns, :matrixes, :xlsx, to: :section_parser

          def initialize(section_parser:, sheet_name:, state:)
            @section_parser = section_parser
            @sheet_name = sheet_name
            @state = state
          end

          def perform
            return Rover::DataFrame.new if validated_defined_data_sources.empty?

            sheet_data.concat(overrides)
          end

          def sheet_data
            @sheet_data ||= validated_data_sources.map(&:frame).inject(Rover::DataFrame.new) { |memo, source_data_frame| memo.concat(source_data_frame) }
          end

          def errors
            @errors ||= error_data_sources.flat_map(&:errors)
          end

          def sheet_columns
            @sheet_columns ||= columns.select { |col| col.sheet_name == sheet_name }.map(&:sheet_column)
          end

          private

          def validated_data_sources
            @validated_data_sources ||= validated_defined_data_sources + dynamically_generated_columns
          end

          def validated_defined_data_sources
            @validated_defined_data_sources ||= (columns + matrixes).select { |data_source| data_source.sheet_name == sheet_name && data_source.valid? }
          end

          def error_data_sources
            @error_data_sources ||= (columns + matrixes).select { |data_source| data_source.sheet_name == sheet_name && data_source.present_on_sheet? }
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

          def dynamically_generated_columns
            @dynamically_generated_columns ||= dynamic_columns.flat_map { |dynamic_column| dynamic_column.columns(sheet: self) }
          end
        end
      end
    end
  end
end
