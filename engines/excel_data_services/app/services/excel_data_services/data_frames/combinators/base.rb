# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      class Base
        attr_reader :coordinator_state
        delegate :file, to: :coordinator_state

        DefaultSheetIteration = Struct.new(:default_state, keyword_init: true)

        def self.state(coordinator_state:)
          new(coordinator_state: coordinator_state).state
        end

        def initialize(coordinator_state:)
          @coordinator_state = coordinator_state
        end

        def schema_state(schema:)
          ExcelDataServices::DataFrames::Combinators::State.new(
            schema: schema,
            errors: [],
            frame: nil,
            hub_id: coordinator_state.hub_id,
            group_id: coordinator_state.group_id,
            organization_id: coordinator_state.organization_id
          )
        end

        def state
          @state ||= ExcelDataServices::DataFrames::Combinators::State.new(
            schema: nil,
            errors: errors,
            frame: frame,
            hub_id: coordinator_state.hub_id,
            group_id: coordinator_state.group_id,
            organization_id: coordinator_state.organization_id
          )
        end

        def frame
          @frame ||= iterations.inject(Rover::DataFrame.new) { |memo, iteration|
            memo.concat(combined_state_frames(iteration: iteration))
          }
        end

        def errors
          @errors ||= iterations.inject([]) { |memo, iteration|
            memo.concat(combined_state_errors(iteration: iteration))
          }
        end

        def combined_state_frames(iteration:)
          iteration.default_state.frame
        end

        def combined_state_errors(iteration:)
          iteration.default_state.errors
        end
      end
    end
  end
end
