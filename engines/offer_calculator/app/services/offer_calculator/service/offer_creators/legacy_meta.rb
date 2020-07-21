# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LegacyMeta
        def self.meta(offer:, shipment:, tender:, scope:)
          new(offer: offer, shipment: shipment, tender: tender, scope: scope).perform
        end

        def initialize(offer:, shipment:, tender:, scope:)
          @offer = offer
          @shipment = shipment
          @tender = tender
          @scope = scope
        end

        def perform
          {
            shipment_id: shipment.id,
            ocean_chargeable_weight: chargeable_weight,
            transshipmentVia: itinerary.transshipment,
            validUntil: valid_until,
            remarkNotes: remark_notes,
            pricing_rate_data: rate_overview,
            charge_trip_id: schedule.trip_id,
            exchange_rates: ResultFormatter::ExchangeRateService.new(tender: tender).perform
          }.merge(routing_info)
        end

        private

        attr_reader :offer, :shipment, :scope, :tender

        def routing_info
          {
            itinerary_id: itinerary.id,
            destination_hub: itinerary.destination_hub,
            transit_time: transit_time,
            load_type: shipment.load_type,
            mode_of_transport: itinerary.mode_of_transport,
            name: itinerary.name,
            service_level: freight_tenant_vehicle.name,
            carrier_name: freight_tenant_vehicle.carrier&.name,
            origin_hub: itinerary.origin_hub,
            tenant_vehicle_id: freight_tenant_vehicle.id
          }.merge(trucking_info)
        end

        def trucking_info
          {
            pre_carriage_carrier: pre_carriage_tenant_vehicle&.carrier&.name,
            on_carriage_carrier: on_carriage_tenant_vehicle&.carrier&.name,
            pre_carriage_service: pre_carriage_tenant_vehicle&.name,
            on_carriage_service: on_carriage_tenant_vehicle&.name,
            pre_carriage_truck_type: tender.pickup_truck_type,
            on_carriage_truck_type: tender.delivery_truck_type
          }
        end

        def schedule
          @schedule ||= offer.schedules.first
        end

        def rate_overview
          return {} if scope.dig(:show_rate_overview).blank?

          OfferCalculator::Service::OfferCreators::RateOverview.overview(offer: offer)
        end

        def itinerary
          @itinerary ||= offer.itinerary
        end

        def freight_tenant_vehicle
          @freight_tenant_vehicle ||= offer.tenant_vehicle(section_key: "cargo")
        end

        def pre_carriage_tenant_vehicle
          @pre_carriage_tenant_vehicle ||= offer.tenant_vehicle(section_key: "trucking_pre")
        end

        def on_carriage_tenant_vehicle
          @on_carriage_tenant_vehicle ||= offer.tenant_vehicle(section_key: "trucking_on")
        end

        def transit_time
          (schedule.eta.to_date - schedule.etd.to_date).to_i
        end

        def valid_until
          offer.valid_until
        end

        def chargeable_weight
          offer.section(key: "cargo").first.fee.measures.kg.value
        end

        def remark_notes
          note_association = Legacy::Note.where(organization_id: shipment.organization_id, remarks: true)
          note_association.where(pricings_pricing_id: offer.pricing_ids(section_key: "cargo"))
            .or(note_association.where(target: shipment.organization))
            .pluck(:body)
        end
      end
    end
  end
end
