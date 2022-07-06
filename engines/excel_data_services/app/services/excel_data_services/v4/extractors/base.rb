# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
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
          state.set_frame(value: extracted, key: target_frame)
          state
        end

        def extracted
          @extracted ||= blank_frame.concat(frame).left_join(extracted_frame, on: join_arguments)
        end

        def extracted_frame
          @extracted_frame ||= blank_frame.concat(Rover::DataFrame.new(frame_data, types: frame_types))
        end

        def blank_frame
          Rover::DataFrame.new(frame_types.keys.each_with_object({}) { |key, result| result[key] = [] }, types: frame.types.merge(frame_types))
        end

        def organization_ids
          @organization_ids ||= frame["organization_id"].to_a.uniq
        end

        def frame
          @frame ||= state.frame(target_frame)
        end
      end
    end
  end
end
