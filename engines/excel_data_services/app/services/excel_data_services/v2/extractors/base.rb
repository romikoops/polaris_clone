# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
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
          @state.frame = extracted
          append_errors_to_state
          state
        end

        def extracted
          @extracted ||= frame.left_join(extracted_frame, on: join_arguments)
        end

        def extracted_frame
          @extracted_frame ||= Rover::DataFrame.new(frame_data, types: frame_types)
        end

        def frame_types
          {}
        end

        def append_errors_to_state
          extracted[extracted[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row)
          end
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

        def blank_frame
          Rover::DataFrame.new([], types: state.frame.types.merge(frame_types))
        end
      end
    end
  end
end
