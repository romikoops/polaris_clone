# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LegacyResponse < OfferCalculator::Service::OfferCreators::Base
        def self.response(charge_breakdown:, meta:, offer:, scope:, async: false)
          new(
            charge_breakdown: charge_breakdown,
            meta: meta,
            offer: offer,
            scope: scope,
            async: async
          ).perform
        end

        def initialize(charge_breakdown:, meta:, offer:, scope:, async: false)
          @charge_breakdown = charge_breakdown
          @meta = meta
          @offer = offer
          @scope = scope
          @async = async
          super(shipment: charge_breakdown.shipment)
        end

        def perform
          {
            quote: quote,
            schedules: schedules_result,
            meta: meta,
            notes: grab_notes
          }
        end

        private

        attr_reader :offer, :charge_breakdown, :meta, :scope, :async

        delegate :tender, to: :charge_breakdown

        def schedules_result
          return offer.schedules.map(&:to_detailed_hash) if offer.present?

          trip_ids = shipment.meta.dig("schedule_ids", tender.id)
          OfferCalculator::Schedule.from_trips(Legacy::Trip.where(id: trip_ids))
        end

        def grab_notes
          tender = charge_breakdown.tender
          hubs = [tender.origin_hub, tender.destination_hub]
          nexii = ::Legacy::Nexus.where(id: hubs.pluck(:nexus_id))
          countries = ::Legacy::Country.where(id: nexii.select(:country_id))
          pricings = ::Pricings::Pricing.where(id: pricing_ids)
          regular_notes = ::Legacy::Note.where(transshipment: false, organization_id: charge_breakdown.shipment.organization_id)
          regular_notes.where(target: hubs | nexii | countries)
            .or(regular_notes.where(pricings_pricing_id: pricings.ids))
        end

        def quote
          return {} if async.present?

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
