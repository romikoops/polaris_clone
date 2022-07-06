# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      class LocationFilter < ExcelDataServices::V4::Operations::Base
        STATE_COLUMNS = %w[hub_id group_id organization_id row sheet_name].freeze
        ZONE_COLUMNS = %w[zone range postal_code distance city province country_code locode].freeze

        def perform
          return state unless identifier == "postal_city"

          state.set_frame(value: filtered_zones, key: "zones")
          state.set_frame(value: filtered_rates, key: "rates")
          state
        end

        private

        def filtered_zones
          @filtered_zones ||= frame.inner_join(expanded_frame, on: { "city" => "city" })
        end

        def filtered_rates
          @filtered_rates ||= filtered_zones.inner_join(rate_frame, on: { "zone" => "zone" })[rate_frame.keys]
        end

        def cities
          @cities ||= frame["city"].to_a.uniq
        end

        def filtered_cities
          @filtered_cities ||= cities.inject(cities.dup) do |memo, city|
            memo.reject { |inner_city| inner_city.starts_with?("#{city} ") }
          end
        end

        def expanded_frame
          @expanded_frame ||= Rover::DataFrame.new({ "city" => filtered_cities })
        end

        def identifier
          @identifier ||= frame["identifier"].to_a.first
        end

        def rate_frame
          @rate_frame ||= state.frame("rates")
        end
      end
    end
  end
end
