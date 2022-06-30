# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class GrdbExcel < ExcelDataServices::V4::Framers::Base
        ALPHA_INDEX = ExcelDataServices::V4::Files::Tables::Column::ALPHA_INDEX

        def framed_data
          @framed_data ||= frame["sheet_name"].to_a.uniq.inject(Rover::DataFrame.new) do |result, sheet_name|
            result.concat(
              GrdbSheet.new(
                sheet_name: sheet_name,
                frame: frame.filter("sheet_name" => sheet_name)
              ).perform
            )
          end
        end

        class GrdbSheet
          def initialize(frame:, sheet_name:)
            @frame = frame
            @sheet_name = sheet_name
          end

          attr_reader :frame, :sheet_name

          def perform
            data_with_coordinate_keys[non_coordinate_keys]
          end

          def data_with_coordinate_keys
            @data_with_coordinate_keys ||= fixed_columns_as_table
              .inner_join(flattened_frame, on: { "row" => "row" })
              .inner_join(overrides, on: { "sheet_name" => "sheet_name" })
          end

          def flattened_frame
            fee_column_ranges.inject(Rover::DataFrame.new) do |memo, column_range|
              memo.concat(fee_table_from_column_range(column_range: column_range))
            end
          end

          def fee_table_from_column_range(column_range:)
            ColumnRangeFrame.new(frame: frame[frame["column"].in?(column_range)], sheet_name: sheet_name).perform
          end

          def fee_column_ranges
            @fee_column_ranges ||= (currency_columns + [last_column_as_number]).each_cons(2).map { |column_a, column_b| column_a.upto(column_b - 1).to_a.map { |column| ALPHA_INDEX.key(column) } }
          end

          def currency_columns
            @currency_columns ||= frame[%w[header column]].inner_join(currency_header_frame, on: { "header" => "header" })["column"].to_a.uniq.map { |column| ALPHA_INDEX[column] }
          end

          def currency_header_frame
            @currency_header_frame ||= Rover::DataFrame.new({ "header" => currency_headers })
          end

          def currency_headers
            @currency_headers ||= frame["header"].to_a.select { |header| header.include?("currency") }.uniq
          end

          def fixed_columns
            @fixed_columns ||= "A".upto(ALPHA_INDEX.key(currency_columns.first - 1)).to_a + ["N/A"]
          end

          def fixed_columns_as_table
            @fixed_columns_as_table ||= ExcelDataServices::V4::Framers::SheetFramer.new(
              sheet_name: sheet_name,
              frame: fixed_columns_and_static_data.filter("sheet_name" => sheet_name)
            ).perform
          end

          def fixed_columns_and_static_data
            @fixed_columns_and_static_data ||= frame[frame["column"].in?(fixed_columns)].concat(frame[frame["column"].missing])
          end

          def overrides
            @overrides ||= ExcelDataServices::V4::Framers::SheetFramer.new(
              sheet_name: sheet_name,
              frame: frame.filter("column" => 0, "row" => 0)
            ).perform.tap do |frame|
              frame.delete("column")
              frame.delete("row")
            end
          end

          def last_column_as_number
            @last_column_as_number ||= frame[!frame["column"].in?([0, "N/A"])]["column"].to_a.map { |column| ALPHA_INDEX[column] }.max
          end

          def non_coordinate_keys
            @non_coordinate_keys ||= data_with_coordinate_keys.keys.grep_v(/(_row|_column)$/)
          end
        end

        class ColumnRangeFrame
          FEE_KEYS = %w[currency rate basis minimum maximum notes effective_date expiration_date sheet_name row].freeze

          def initialize(frame:, sheet_name:)
            @frame = frame
            @sheet_name = sheet_name
          end

          def perform
            table_with_headers.tap do |tapped_frame|
              tapped_frame["fee_code"] = fee_name_header.downcase.gsub(/\s/, "_")
              tapped_frame["fee_name"] = fee_name_header.humanize
              tapped_frame["rate"] = tapped_frame.delete(fee_name_header)
            end
          end

          private

          attr_reader :frame, :column_range, :sheet_name

          def table_with_headers
            @table_with_headers ||= ExcelDataServices::V4::Framers::SheetFramer.new(frame: frame_with_correct_headers, sheet_name: sheet_name).perform
          end

          def frame_with_correct_headers
            @frame_with_correct_headers ||= frame.tap { |inner_frame| inner_frame["header"].map! { |header| header.split(":").last } }
          end

          def fee_name_header
            @fee_name_header ||= table_with_headers.keys.find do |frame_key|
              FEE_KEYS.exclude?(frame_key) && frame_key.exclude?("row") && frame_key.exclude?("column")
            end
          end
        end
      end
    end
  end
end
