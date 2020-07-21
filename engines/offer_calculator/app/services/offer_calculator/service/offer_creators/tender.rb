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
          assign_routing_attributes
          assign_trucking_attributes
          tender.save!
          tender
        end

        private

        attr_reader :tender, :shipment, :quotation, :offer

        delegate :itinerary, to: :offer

        def assign_routing_attributes
          tender.assign_attributes(
            carrier_name: freight_tenant_vehicle.carrier&.name,
            tenant_vehicle_id: freight_tenant_vehicle.id,
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

        def assign_trucking_attributes
          tender.assign_attributes(
            pickup_tenant_vehicle: offer.tenant_vehicle(section_key: "trucking_pre"),
            delivery_tenant_vehicle: offer.tenant_vehicle(section_key: "trucking_on"),
            pickup_truck_type: offer.truck_type(carriage: "pre"),
            delivery_truck_type: offer.truck_type(carriage: "on")
          )
        end

        def freight_tenant_vehicle
          @freight_tenant_vehicle ||= offer.tenant_vehicle(section_key: "cargo")
        end
      end
    end
  end
end
