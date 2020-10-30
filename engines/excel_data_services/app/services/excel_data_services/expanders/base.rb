# frozen_string_literal: true

module ExcelDataServices
  module Expanders
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
        @state.frame = expanded
        state
      end

      def expanded
        frame.left_join(expanded_frame, on: join_arguments)
      end

      def initial_frame
        @initial_frame ||= Rover::DataFrame.new(frame_structure)
      end
    end
  end
end
