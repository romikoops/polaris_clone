# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Tender < OfferCalculator::Service::OfferCreators::Base
        def self.tender(offer:, shipment:, quotation:)
          new(offer: offer, shipment: shipment, quotation: quotation).perform
        end

        def initialize(offer:, shipment:, quotation:)
          @offer = offer
          @shipment = shipment
          @quotation = quotation
          @tender = ::Quotations::Tender.new
          super(shipment: shipment)
        end

        def perform
          update_tender
          tender
        end

        private

        attr_reader :tender, :shipment, :quotation, :offer

        def update_tender
          itinerary = offer.itinerary
          freight_tenant_vehicle = offer.tenant_vehicle(section_key: "cargo")
          tender.update(
            carrier_name: freight_tenant_vehicle.carrier&.name,
            tenant_vehicle_id: freight_tenant_vehicle.id,
            pickup_tenant_vehicle: offer.tenant_vehicle(section_key: "trucking_pre"),
            delivery_tenant_vehicle: offer.tenant_vehicle(section_key: "trucking_on"),
            load_type: shipment.load_type,
            name: itinerary.name,
            itinerary: itinerary,
            quotation: quotation,
            origin_hub: itinerary.origin_hub,
            destination_hub: itinerary.destination_hub,
            amount: offer.total,
            original_amount: offer.total,
            transshipment: itinerary.transshipment
          )
        end
      end
    end
  end
end
