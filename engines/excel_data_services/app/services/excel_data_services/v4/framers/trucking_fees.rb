# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Framers
      class TruckingFees
        DEFAULT_FRAME_KEYS = %w[rate_type mode_of_transport row sheet_name group_name group_id zone service carrier
          carrier_code direction truck_type cargo_class min max fee_name fee_code currency rate_basis range_min
          range_max base rate].freeze

        def initialize(frame:)
          @frame = frame
        end

        def perform
          blank_frame.concat(Rover::DataFrame.new(fee_rows_for_frame))
        end

        private

        attr_reader :frame

        def fee_rows_for_frame
          frame_grouped_by_row.map do |row_values|
            row_from_values(row_values: row_values)
          end
        end

        def row_from_values(row_values:)
          row_values.inject({ "rate_type" => "trucking_fee", "mode_of_transport" => "truck_carriage" }) do |memo, row|
            cleaned_row = CleanedRowPerValue.new(row: row)

            next memo if cleaned_row.rate_cell? && cleaned_row.no_value?

            memo.merge(cleaned_row.to_h)
          end
        end

        def frame_grouped_by_row
          @frame_grouped_by_row ||= frame_from_fees_sheet.to_a.group_by { |frame_row| frame_row["row"] }.values
        end

        def frame_from_fees_sheet
          @frame_from_fees_sheet ||= frame[(frame["sheet_name"] == "Fees")]
        end

        def blank_frame
          @blank_frame ||= Rover::DataFrame.new(DEFAULT_FRAME_KEYS.zip([] * DEFAULT_FRAME_KEYS.size).to_h)
        end

        class CleanedRowPerValue
          FEE_RATE_KEYS = %w[ton cbm kg item shipment bill container wm percentage].freeze

          def initialize(row:)
            @row = row
            @header = row["header"]
            @value = row["value"]
          end

          def rate_cell?
            @rate_cell ||= FEE_RATE_KEYS.include?(header)
          end

          def no_value?
            value.nil?
          end

          def to_h
            row.except("header", "value").merge(header_attr => value)
          end

          private

          attr_reader :row, :header, :value

          def header_attr
            rate_cell? ? "rate" : header
          end
        end
      end
    end
  end
end
