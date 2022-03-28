# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      # Operations are a flexible means of manipulating data in the upload pipeline. All Operations take a State object and return one in kind.
      class Base
        attr_reader :state

        def self.state(state:)
          new(state: state).perform
        end

        def initialize(state:)
          @state = state
        end

        def perform
          return state if frame.empty?

          state.frame = operation_result
          state
        end

        def operation_result
          raise NotImplementedError, "This method must be implemented in #{self.class.name} "
        end

        def empty_frame
          Rover::DataFrame.new({ "sheet_name" => [], "row" => [] })
        end

        delegate :frame, to: :state
      end
    end
  end
end
