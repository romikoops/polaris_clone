# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Overlaps
      class Resolver
        # The Resolver class will take the conflict keys andd extract the permutations from the data frame.
        # It will then find all conflicts that exists for each pair and execute the Overlaps handler for that conflict type

        delegate :frame, to: :state

        def self.state(state:, model:, keys:)
          new(state: state, model: model, keys: keys).perform
        end

        def initialize(state:, model:, keys:)
          @state = state
          @model = model
          @keys = keys
        end

        def perform
          return state if state.failed?

          frame[keys].to_a.uniq.each do |conflict_targets|
            handle_overlap(arguments: conflict_targets)
          end
          state
        end

        private

        attr_reader :state, :keys, :model

        def handle_overlap(arguments:)
          ExcelDataServices::V2::Overlaps::Detector.overlaps(
            table: model.table_name, arguments: arguments
          ).each do |conflict_type|
            ExcelDataServices::V2::Overlaps.const_get(conflict_type.camelize).new(model: model, arguments: arguments).perform
          end
        end
      end
    end
  end
end
