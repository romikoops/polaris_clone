# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class SequentialDates < ExcelDataServices::V2::Validators::Base
        def extract_state
          @state
        end

        def append_errors_to_state
          frame.each_row do |frame_row|
            append_error(row: frame_row) unless frame_row["expiration_date"] > frame_row["effective_date"]
          end
        end

        def error_reason(row:)
          "The expiration date ('#{row['expiration_date']}) lies before the effective date ('#{row['effective_date']})."
        end
      end
    end
  end
end
