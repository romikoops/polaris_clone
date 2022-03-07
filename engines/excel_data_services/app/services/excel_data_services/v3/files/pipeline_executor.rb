# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class PipelineExecutor
        attr_reader :state, :sheet_parser

        def initialize(state:, sheet_parser:)
          @state = state
          @sheet_parser = sheet_parser
        end

        def perform
          execute_actions(actions: global_actions)
          connected_actions.each do |connected_action|
            return state if failed?

            execute_actions(actions: connected_action.actions)
          end
          state
        end

        private

        def failed?
          state.errors.present?
        end

        def execute_actions(actions:)
          @state = ExcelDataServices::V3::Files::ActionExecutor.new(state: state, actions: actions).perform
        end

        delegate :global_actions, :connected_actions, to: :sheet_parser
      end
    end
  end
end
