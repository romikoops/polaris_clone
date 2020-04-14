# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class CapabilityService < Api::Routing::Trucking::Base
        def self.capability(tenant:, load_type:)
          new(tenant: tenant, load_type: load_type).perform
        end

        def initialize(tenant:, load_type:)
          super(tenant: tenant, load_type: load_type, target: nil)
        end

        def perform
          { origin: origin_capability, destination: destination_capability }
        end

        private

        def origin_capability
          type_availabilities(target_index: ORIGIN_INDEX).exists?(carriage: 'pre')
        end

        def destination_capability
          type_availabilities(target_index: DESTINATION_INDEX).exists?(carriage: 'on')
        end
      end
    end
  end
end
