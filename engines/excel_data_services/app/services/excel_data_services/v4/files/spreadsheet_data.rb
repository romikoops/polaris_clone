# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class SpreadsheetData
        attr_reader :state, :section_parser

        delegate :sheets, to: :section_parser

        def initialize(state:, section_parser:)
          @state = state
          @section_parser = section_parser
        end

        def frame
          @frame ||= data_sources.inject(Rover::DataFrame.new) do |result, sheet_object|
            result.concat(sheet_object.perform)
          end
        end

        def errors
          @errors ||= data_sources.flat_map(&:errors)
        end

        private

        def data_sources
          @data_sources ||= if state.xml?
            [ExcelDataServices::V4::Files::Tables::Xml.new(state: state, section_parser: section_parser)]
          else
            sheets.map { |sheet_name| ExcelDataServices::V4::Files::Tables::Sheet.new(state: state, sheet_name: sheet_name, section_parser: section_parser) }
          end
        end
      end
    end
  end
end
