# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Base
        attr_reader :state

        delegate :frame, to: :state

        def self.state(state:)
          new(state: state).perform
        end

        def initialize(state:)
          @state = state
        end

        def perform
          extract_state
          append_errors_to_state
          state
        end

        def append_errors_to_state
          frame[frame[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row)
          end
        end

        def extract_state
          @state = extracted
        end

        def append_error(row:)
          @state.errors << ExcelDataServices::V2::Error.new(
            type: :warning,
            row_nr: row["row"],
            sheet_name: row["sheet_name"],
            reason: error_reason(row: row),
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
