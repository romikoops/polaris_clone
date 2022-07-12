# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Tables
        class Xml
          attr_reader :section_parser, :state

          delegate :xml, to: :state
          delegate :xml_columns, :xml_data, to: :section_parser

          def initialize(section_parser:, state:)
            @section_parser = section_parser
            @state = state
          end

          def perform
            xml_columns.map(&:frame).inject(base_frame) { |memo, source_data_frame| memo.concat(source_data_frame) }
          end

          def errors
            @errors ||= xml_columns.flat_map(&:errors)
          end

          private

          def base_frame
            @base_frame ||= Rover::DataFrame.new(
              xml_data.identifiers.flat_map do |identifier|
                state.overrides.data.map do |key, value|
                  {
                    "value" => value,
                    "header" => key,
                    "row" => 0,
                    "column" => 0,
                    "sheet_name" => identifier
                  }
                end
              end
            )
          end
        end
      end
    end
  end
end
