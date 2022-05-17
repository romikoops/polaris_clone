# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class SequentialDates < ExcelDataServices::V4::Validators::Base
        DATE_PAIRS = [
          %w[effective_date expiration_date],
          %w[origin_departure destination_arrival],
          %w[closing_date origin_departure]
        ].freeze

        def extract_state
          @state
        end

        def append_errors_to_state
          frame.each_row do |frame_row|
            append_error(row: frame_row) unless row_is_valid?(row: frame_row)
          end
        end

        def row_is_valid?(row:)
          DATE_PAIRS.all? do |date_pair|
            next true unless row.values_at(*date_pair).all?(&:present?)

            row[date_pair.first] <= row[date_pair.last]
          end
        end

        def error_reason(row:)
          date_pair = DATE_PAIRS.find { |pair| row.values_at(*pair).all?(&:present?) }
          "The #{date_pair.last.humanize} ('#{row[date_pair.last]}) lies before the #{date_pair.first.humanize} ('#{row[date_pair.first]})."
        end

        def key_base
          "expiration_date"
        end
      end
    end
  end
end
