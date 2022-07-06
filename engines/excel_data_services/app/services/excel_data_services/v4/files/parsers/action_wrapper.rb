# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class ActionWrapper
          attr_reader :action, :target_frame

          def initialize(action:, target_frame:)
            @action = action
            @target_frame = target_frame
          end

          def state(state:)
            action.new(state: state, target_frame: target_frame).perform
          end
        end
      end
    end
  end
end
