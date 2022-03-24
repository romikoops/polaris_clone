# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Framers
      class Base
        attr_reader :section_parser, :state

        def initialize(state:, section_parser:)
          @state = state
          @section_parser = section_parser
        end

        def perform
          defined_frame.concat(framed_data).left_join(overrides, on: { "organization_id" => "organization_id" })
        end

        delegate :errors, :frame, to: :spreadsheet_cell_data

        private

        def spreadsheet_cell_data
          @spreadsheet_cell_data ||= ExcelDataServices::V3::Files::SpreadsheetData.new(state: state, section_parser: section_parser)
        end

        def values
          # rubocop:disable Style/NumericPredicate .positive? not a Vector method
          @values ||= frame[frame["row"] > 0]
          # rubocop:enable Style/NumericPredicate
        end

        def overrides
          @overrides ||= Rover::DataFrame.new(
            sheet_names.map do |sheet_name|
              frame.filter({ "row" => 0, "sheet_name" => sheet_name }).to_a.inject({ "sheet_name" => sheet_name }) do |memo, override|
                memo.merge(override["header"] => override["value"])
              end
            end
          )
        end

        def headers
          @headers ||= values["header"].to_a.uniq
        end

        def sheet_names
          @sheet_names ||= values["sheet_name"].to_a.uniq
        end

        def prefixed_column_mapper(mapped_object:, header:)
          ExcelDataServices::V3::Helpers::PrefixedColumnMapper.new(mapped_object: mapped_object, header: header).perform
        end

        def defined_frame
          @defined_frame ||= Rover::DataFrame.new(section_parser.headers.each_with_object({}) { |header, result| result[header] = [] })
        end
      end
    end
  end
end
