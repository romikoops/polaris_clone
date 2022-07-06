# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Distributors
      class Distributor
        attr_reader :state

        delegate :frame, to: :state

        def self.state(state:)
          new(state: state).perform
        end

        def initialize(state:)
          @state = state
        end

        def perform
          state.frames.each do |frame_key, sub_frame|
            state.set_frame(
              value: DistributedFrame.new(frame: sub_frame, section: state.section, file_id: state.file.id).perform,
              key: frame_key
            )
          end
          @state
        end

        class DistributedFrame
          def initialize(frame:, section:, file_id:)
            @frame = frame
            @section = section
            @file_id = file_id
          end

          def perform
            return frame if distributable_frame.blank?

            actions.inject(distributable_frame) do |memo, action|
              perform_action(action: action, result_frame: memo)
            end
          end

          private

          attr_reader :frame, :section, :file_id

          def perform_action(action:, result_frame:)
            action_klass = "ExcelDataServices::V4::Distributors::Actions::#{action.action_type.camelize}".constantize
            action_klass.new(frame: result_frame, action: action).perform.tap do
              Distributions::Execution.create!(action: action, file_id: file_id)
            end
          end

          def distributable_frame
            @distributable_frame ||= frame.filter("distribute" => true)
          end

          def actions
            @actions ||= Distributions::Action.where(organization: Organizations::Organization.current, upload_schema: section).order(:order)
          end
        end
      end
    end
  end
end
