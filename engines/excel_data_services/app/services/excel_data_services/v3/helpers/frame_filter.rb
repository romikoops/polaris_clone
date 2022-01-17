# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Helpers
      class FrameFilter
        def initialize(input_frame:, arguments:)
          @input_frame = input_frame
          @arguments = arguments
        end

        def frame
          input_frame[arguments.keys.map { |key| (input_frame[key] == arguments[key]) }.reduce(&:&)]
        end

        private

        attr_reader :input_frame, :arguments
      end
    end
  end
end
