# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LegacyResponse
        def self.response(charge_breakdown:, meta:, offer:, scope:)
          new(
            charge_breakdown: charge_breakdown,
            meta: meta,
            offer: offer,
            scope: scope
          ).perform
        end

        def initialize(charge_breakdown:, meta:, offer:, scope:)
          @charge_breakdown = charge_breakdown
          @meta = meta
          @offer = offer
          @scope = scope
        end

        def perform
          {
            quote: quote,
            schedules: offer.schedules.map(&:to_detailed_hash),
            meta: meta,
            notes: grab_notes
          }
        end

        private

        attr_reader :offer, :charge_breakdown, :meta, :scope

        def grab_notes
          tender = charge_breakdown.tender
          hubs = [tender.origin_hub, tender.destination_hub]
          nexii = ::Legacy::Nexus.where(id: hubs.pluck(:nexus_id))
          countries = ::Legacy::Country.where(id: nexii.select(:country_id))
          pricings = ::Pricings::Pricing.where(id: offer.pricing_ids(section_key: "cargo"))
          regular_notes = ::Legacy::Note.where(transshipment: false, organization_id: charge_breakdown.shipment.organization_id)
          regular_notes.where(target: hubs | nexii | countries)
            .or(regular_notes.where(pricings_pricing_id: pricings.ids))
        end

        def quote
          OfferCalculator::Service::OfferCreators::EnhancedQuote.quote(
            offer: offer,
            charge_breakdown: charge_breakdown,
            scope: scope
          )
        end
      end
    end
  end
end
