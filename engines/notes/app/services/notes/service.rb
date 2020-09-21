# frozen_string_literal: true

module Notes
  class Service
    attr_reader :tender, :remarks, :charge_breakdown, :organization, :itinerary

    def initialize(tender:, remarks: false)
      @tender = tender
      @remarks = remarks
      @charge_breakdown = tender.charge_breakdown
      @organization = tender.quotation.organization
      @itinerary = tender.itinerary
    end

    def fetch
      note_association = Legacy::Note.where(organization_id: organization.id, remarks: remarks)
      note_association.where(target: hubs | nexii | countries | [itinerary])
        .or(note_association.where(pricings_pricing_id: pricing_ids))
        .or(note_association.where(target: nil, pricings_pricing_id: nil))
        .select("DISTINCT ON (body) body, *")
        .order(:body)
    end

    def hubs
      @hubs ||= [tender.origin_hub, tender.destination_hub]
    end

    def nexii
      @nexii ||= ::Legacy::Nexus.where(id: hubs.pluck(:nexus_id))
    end

    def countries
      @countries ||= ::Legacy::Country.where(id: nexii.select(:country_id))
    end

    def pricing_ids
      Pricings::Pricing.where(itinerary: tender.itinerary, tenant_vehicle: tender.tenant_vehicle)
    end
  end
end
