# frozen_string_literal: true

module OfferCalculator
  module Service
    class OfferCreator < Base
      def self.offers(shipment:, quotation:, offers:, wheelhouse:, async:)
        new(
          shipment: shipment,
          quotation: quotation,
          offers: offers,
          wheelhouse: wheelhouse,
          async: async
        ).perform
      end

      def initialize(shipment:, quotation:, offers:, wheelhouse:, async:)
        @offers = offers
        @wheelhouse = wheelhouse
        @async = async
        super(shipment: shipment, quotation: quotation)
      end

      def perform
        results = offers.map { |offer| handle_offer(offer: offer) }
        quotation.update(completed: true)
        results
      end

      private

      attr_reader :offers, :shipment, :quotation, :wheelhouse, :async

      def handle_offer(offer:)
        tender = OfferCalculator::Service::OfferCreators::Tender.tender(
          offer: offer, shipment: shipment, quotation: quotation
        )
        OfferCalculator::Service::OfferCreators::LineItems.line_items(
          offer: offer, shipment: shipment, tender: tender
        )
        legacy_charge_breakdown = OfferCalculator::Service::OfferCreators::LegacyChargeBreakdown.charge_breakdown(
          offer: offer, shipment: shipment, tender: tender
        )
        OfferCalculator::Service::OfferCreators::Metadatum.metadatum(
          offer: offer, shipment: shipment, tender: tender, charge_breakdown: legacy_charge_breakdown
        )
        return tender if wheelhouse.present?

        legacy_meta = OfferCalculator::Service::OfferCreators::LegacyMeta.meta(
          offer: offer, shipment: shipment, tender: tender, scope: scope
        )
        OfferCalculator::Service::OfferCreators::LegacyResponse.response(
          offer: offer,
          charge_breakdown: legacy_charge_breakdown,
          meta: legacy_meta,
          scope: scope,
          async: async
        )
      rescue => e
        Raven.capture_exception(e)
        raise OfferCalculator::Errors::OfferBuilder
      end
    end
  end
end
