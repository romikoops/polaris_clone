# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Base
        attr_reader :state, :target_frame

        def self.state(state:, target_frame: "default")
          new(state: state, target_frame: target_frame).perform
        end

        def initialize(state:, target_frame:)
          @state = state
          @target_frame = target_frame
        end

        def perform
          extract_state
          append_errors_to_state
          state
        end

        def append_errors_to_state
          filtered_frame[filtered_frame[required_key].missing].to_a.each do |error_row|
            append_error(row: error_row)
          end
        end

        def extract_state
          @state = extracted
        end

        def append_error(row:)
          @state.errors << ExcelDataServices::V4::Error.new(
            type: :warning,
            row_nr: row[row_key],
            col_nr: row[col_key],
            sheet_name: row["sheet_name"],
            reason: error_reason(row: row),
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def required_key
          "#{key_base}_id"
        end

        def col_key
          "#{key_base}_column"
        end

        def row_key
          "row"
        end

        def error_reason(row:)
          "The #{key_base.humanize} '#{row[key_base]}' cannot be found."
        end

        def key_base
          self.class.name.demodulize.underscore.downcase
        end

        def filtered_frame
          @filtered_frame ||= extracted.frame(target_frame)
        end

        def frame
          @frame ||= state.frame(target_frame)
        end
      end
    end
  end
end
