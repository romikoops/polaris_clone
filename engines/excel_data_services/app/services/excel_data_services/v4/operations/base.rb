# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      # Operations are a flexible means of manipulating data in the upload pipeline. All Operations take a State object and return one in kind.
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
          return state if frame.empty?

          set_extracted_frame
          state
        end

        def operation_result
          raise NotImplementedError, "This method must be implemented in #{self.class.name} "
        end

        def empty_frame
          Rover::DataFrame.new({ "sheet_name" => [], "row" => [] })
        end

        def frame
          @frame ||= state.frame(target_frame)
        end

        def set_extracted_frame
          state.set_frame(value: operation_result, key: target_frame)
        end
      end
    end
  end
end
