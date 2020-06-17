# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class CountriesService < Api::Routing::Trucking::Base
        def perform
          Legacy::Country.where(id: nexuses.select(:country_id)).distinct
        end

        private

        def nexuses
          hub_ids = type_availabilities(target_index: target).select("hubs.id")

          ::Legacy::Nexus.joins(:hubs).where(hubs: {id: hub_ids})
        end
      end
    end
  end
end
