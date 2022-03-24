# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class SpreadsheetData
        attr_reader :state, :section_parser

        delegate :sheets, to: :section_parser

        def initialize(state:, section_parser:)
          @state = state
          @section_parser = section_parser
        end

        def frame
          @frame ||= table_sheets.inject(Rover::DataFrame.new) do |result, sheet_object|
            result.concat(sheet_object.perform)
          end
        end

        def errors
          @errors ||= table_sheets.flat_map(&:errors)
        end

        private

        def table_sheets
          @table_sheets ||= sheets.map { |sheet_name| ExcelDataServices::V3::Files::Tables::Sheet.new(state: state, sheet_name: sheet_name, section_parser: section_parser) }
        end
      end
    end
  end
end
