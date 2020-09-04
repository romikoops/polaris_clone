# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class DetailsService
        attr_reader :coordinates, :nexus_id, :load_type
        def initialize(coordinates:, nexus_id:, load_type:)
          @coordinates = coordinates
          @nexus_id = nexus_id
          @load_type = load_type
        end
      end
    end
  end
end
