# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      class ActionExecutor
        attr_reader :state, :actions

        def initialize(state:, actions:)
          @state = state
          @actions = actions
        end

        def perform
          actions.each do |action|
            break if failed?

            @state = action.state(state: state)
          end
          state
        end

        def failed?
          state.errors.present?
        end
      end
    end
  end
end
