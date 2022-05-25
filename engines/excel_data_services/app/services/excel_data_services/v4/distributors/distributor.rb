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
          return state if distributable_frame.blank?

          @state.frame = distribution_result
          @state
        end

        private

        def distribution_result
          actions.inject(distributable_frame) do |memo, action|
            perform_action(action: action, result_frame: memo)
          end
        end

        def perform_action(action:, result_frame:)
          action_klass = "ExcelDataServices::V4::Distributors::Actions::#{action.action_type.camelize}".constantize
          action_klass.new(frame: result_frame, action: action).perform.tap do |_result|
            Distributions::Execution.create!(action: action, file_id: state.file.id)
          end
        end

        def distributable_frame
          @distributable_frame ||= frame.filter("distribute" => true)
        end

        def actions
          @actions ||= Distributions::Action.where(organization: Organizations::Organization.current, upload_schema: state.section).order(:order)
        end
      end
    end
  end
end
