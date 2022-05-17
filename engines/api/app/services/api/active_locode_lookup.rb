# frozen_string_literal: true

module Api
  class ActiveLocodeLookup
    def perform
      Rails.cache.fetch("#{pricings.cache_key}/active_locodes", expires_in: 12.hours) do
        available_export_lookup.deep_merge(available_import_lookup)
      end
    end

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
      @available_export_lookup ||= itineraries.joins(origin_hub: :nexus).select("nexuses.locode").distinct.pluck(:locode).each_with_object({}) do |locode, memo|
        memo[locode] = { export: true }
      end
    end

    def available_import_lookup
      @available_import_lookup ||= itineraries.joins(destination_hub: :nexus).select("nexuses.locode").distinct.pluck(:locode).each_with_object({}) do |locode, memo|
        memo[locode] = { import: true }
      end
    end
  end
end
