# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class ExistingClient < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Client.state(state: state)
        end

        def error_reason(row:)
          "The client '#{row['email']}' already exists."
        end

        def append_errors_to_state
          frame[!frame["user_id"].missing].to_a.each do |error_row|
            append_error(row: error_row)
          end
        end
      end
    end
  end
end
