# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class DataFramer
        attr_reader :state, :sheet_parser

        def initialize(state:, sheet_parser:)
          @state = state
          @sheet_parser = sheet_parser
        end

        def perform
          @state.frame = framer.new(frame: spreadsheet_cell_data.frame).perform
          @state.errors += spreadsheet_cell_data.errors
          state
        end

        private

        def spreadsheet_cell_data
          @spreadsheet_cell_data ||= ExcelDataServices::V3::Files::SpreadsheetData.new(state: state, sheet_parser: sheet_parser)
        end

        delegate :framer, to: :sheet_parser
      end
    end
  end
end
