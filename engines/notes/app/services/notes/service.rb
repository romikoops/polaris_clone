# frozen_string_literal: true

module Notes
  class Service
    attr_reader :tenant_vehicle, :remarks, :organization, :itinerary

    def initialize(itinerary:, tenant_vehicle:, remarks: false)
      @tenant_vehicle = tenant_vehicle
      @remarks = remarks
      @organization = itinerary.organization
      @itinerary = itinerary
    end

    def fetch
      note_association.where(target: hubs | nexii | countries | [itinerary])
        .or(note_association.where(pricings_pricing_id: pricing_ids))
        .or(note_association.where(target: nil, pricings_pricing_id: nil))
        .order(:body)
        .select("DISTINCT ON (body) body, *")
    end

    def note_association
      @note_association ||= Legacy::Note.where(organization_id: organization.id, remarks: remarks)
    end

    def hubs
      @hubs ||= [itinerary.origin_hub, itinerary.destination_hub]
    end

    def nexii
      @nexii ||= ::Legacy::Nexus.where(id: hubs.pluck(:nexus_id))
    end

    def countries
      @countries ||= ::Legacy::Country.where(id: nexii.select(:country_id))
    end

    def pricing_ids
      Pricings::Pricing.where(itinerary: itinerary, tenant_vehicle: tenant_vehicle)
    end
  end
end
