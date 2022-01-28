# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Framers
      class Base
        attr_reader :frame

        def initialize(frame:)
          @frame = frame
        end

        private

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
      end
    end
  end
end
