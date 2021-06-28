# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module Extractions
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
          error_rows.each do |error_row|
            append_error(row: error_row)
          end

          @state
        end

        def error_rows
          return frame.to_a unless frame.include?(required_key)

          frame[frame[required_key].missing].to_a
        end

        def required_key
          raise NotImplementedError, "This method must be implemented in #{self.class.name}"
        end
      end
    end
  end
end
