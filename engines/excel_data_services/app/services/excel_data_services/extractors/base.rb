# frozen_string_literal: true

module ExcelDataServices
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
    end
  end
end
