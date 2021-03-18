# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Runners
      class Base
        attr_reader :file, :arguments, :stats
        RunnerState = Struct.new(:file, :frame, :errors, :hub_id, :group_id, :organization_id, keyword_init: true)

        def initialize(file:, arguments:)
          @file = file
          @arguments = arguments.stringify_keys
          @stats = {errors: []}
        end

        def merge_stats(result:)
          @stats.merge!(result.mergeable_stats)

          @stats[:errors] |= result.errors
        end

        def handle_errors
          @stats[:errors] = coordinator_errors
          stats
        end

        def runner_state
          ExcelDataServices::DataFrames::Runners::State.new(
            file: file,
            errors: [],
            frame: nil,
            hub_id: arguments["hub_id"],
            group_id: arguments["group_id"],
            organization_id: arguments["organization_id"]
          )
        end
      end
    end
  end
end
