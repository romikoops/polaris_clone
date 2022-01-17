# frozen_string_literal: true

module ExcelDataServices
  module V3
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
          @extracted ||= blank_frame.concat(frame).left_join(extracted_frame, on: join_arguments)
        end

        def extracted_frame
          @extracted_frame ||= blank_frame.concat(Rover::DataFrame.new(frame_data, types: frame_types))
        end

        def blank_frame
          Rover::DataFrame.new(frame_types.keys.each_with_object({}) { |key, result| result[key] = [] }, types: state.frame.types.merge(frame_types))
        end
      end
    end
  end
end
