# frozen_string_literal: true

module Api
  class ActiveLocodeLookup
    def perform
      Rails.cache.fetch("#{pricings.cache_key}/active_locodes", expires_in: 12.hours) do
        available_export_lookup.deep_merge(available_import_lookup)
      end
    end

    private

    def organization
      @organization ||= Organizations::Organization.find(Organizations.current_id)
    end

    def pricings
      @pricings ||= Pricings::Pricing.where(organization: organization).current
    end

    def itineraries
      @itineraries ||= Legacy::Itinerary.where(organization: organization, id: pricings.select(:itinerary_id))
    end

    def available_export_lookup
      @available_export_lookup ||= distinct_origin_nexuses.pluck(:locode).each_with_object({}) do |locode, memo|
        memo[locode] = { export: true }
      end
    end

    def available_import_lookup
      @available_import_lookup ||= distinct_destination_nexuses.pluck(:locode).each_with_object({}) do |locode, memo|
        memo[locode] = { import: true }
      end
    end

    def distinct_origin_nexuses
      @distinct_origin_nexuses ||= origin_pricing_group_nexuses.or(origin_nexuses).distinct
    end

    def distinct_destination_nexuses
      @distinct_destination_nexuses ||= destination_pricing_group_nexuses.or(destination_nexuses).distinct
    end

    def origin_nexuses
      @origin_nexuses ||= nexuses.where(id: itineraries.joins(:origin_hub).select(:nexus_id))
    end

    def destination_nexuses
      @destination_nexuses ||= nexuses.where(id: itineraries.joins(:destination_hub).select(:nexus_id))
    end

    def origin_pricing_group_nexuses
      @origin_pricing_group_nexuses ||= nexuses.where(id: origin_pricing_groups.pluck(:nexus_id))
    end

    def destination_pricing_group_nexuses
      @destination_pricing_group_nexuses ||= nexuses.where(id: destination_pricing_groups.pluck(:nexus_id))
    end

    def origin_pricing_groups
      @origin_pricing_groups ||= pricings_location_groups.where(name: pricings_location_groups.where(nexus: origin_nexuses).select(:name))
    end

    def destination_pricing_groups
      @destination_pricing_groups ||= pricings_location_groups.where(name: pricings_location_groups.where(nexus: destination_nexuses).select(:name))
    end

    def nexuses
      @nexuses ||= Legacy::Nexus.where(organization: organization)
    end

    def pricings_location_groups
      @pricings_location_groups ||= Pricings::LocationGroup.where(organization: organization)
    end
  end
end
