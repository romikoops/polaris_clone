# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class Conflict
        # This class defines the keys for a given model which are to be used to checking conflicts and triggers the Overlaps::Resolver class

        attr_reader :model, :keys

        def initialize(model:, keys:)
          @model = model
          @keys = keys
        end

        def state(state:)
          ExcelDataServices::V4::Overlaps::Resolver.state(state: state, model: model, keys: keys)
        end
      end
    end
  end
end
