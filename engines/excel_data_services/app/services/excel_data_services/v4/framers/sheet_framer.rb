# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class SheetFramer
        def initialize(frame:, sheet_name:)
          @frame = frame
          @sheet_name = sheet_name
        end

        def perform
          Rover::DataFrame.new(frame_data, types: frame_types)
        end

        private

        attr_reader :frame, :sheet_name

        def frame_data
          headers.inject(sheet_name_and_row) do |result, header|
            result.inner_join(header_formatted_frame(header: header), on: { "row" => "#{header}_row" })
          end
        end

        def sheet_values
          @sheet_values ||= frame.filter({ "sheet_name" => sheet_name })
        end

        def sheet_name_and_row
          @sheet_name_and_row ||= Rover::DataFrame.new(sheet_values[%w[sheet_name row target_frame]].to_a.uniq, types: frame_types)
        end

        def headers
          @headers ||= sheet_values["header"].to_a.uniq
        end

        def header_formatted_frame(header:)
          rows = sheet_values[sheet_values["header"] == header][%w[value row column]]
          ExcelDataServices::V4::Helpers::PrefixedColumnMapper.new(mapped_object: rows, header: header).perform
        end

        def frame_types
          @frame_types ||= headers.inject({}) do |type_obj, header|
            type_obj.merge({
              header => :object,
              "#{header}_row" => :object,
              "#{header}_column" => :object
            })
          end
        end
      end
    end
  end
end
