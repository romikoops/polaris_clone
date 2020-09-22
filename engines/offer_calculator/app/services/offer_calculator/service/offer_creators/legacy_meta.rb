# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class LegacyMeta < OfferCalculator::Service::OfferCreators::Base
        def self.meta(offer:, shipment:, tender:, scope:)
          new(offer: offer, shipment: shipment, tender: tender, scope: scope).perform
        end

        def initialize(offer:, shipment:, tender:, scope:)
          @offer = offer
          @tender = tender
          @scope = scope
          super(shipment: shipment)
        end

        def perform
          set_schedules_result
          {
            tender_id: tender.id,
            shipment_id: shipment.id,
            ocean_chargeable_weight: chargeable_weight,
            transshipmentVia: itinerary.transshipment,
            validUntil: valid_until,
            remarkNotes: remark_notes,
            pricing_rate_data: rate_overview,
            charge_trip_id: schedule.trip_id,
            tender_id: tender.id,
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
          @schedule ||= OfferCalculator::Schedule.from_trip(tender.trip)
        end

        def rate_overview
          return {} if scope.dig(:show_rate_overview).blank?

          tender_rate_overview = shipment.meta.dig("rate_overviews", tender.id)
          return tender_rate_overview if tender_rate_overview.present?
          return {} if offer.blank?

          update_shipment_meta(key: "rate_overviews", value: rate_overview_hash)
          rate_overview_hash
        end

        def rate_overview_hash
          @rate_overview_hash ||= OfferCalculator::Service::OfferCreators::RateOverview.overview(offer: offer)
        end

        def itinerary
          @itinerary ||= tender.itinerary
        end

        def freight_tenant_vehicle
          @freight_tenant_vehicle ||= tender.tenant_vehicle
        end

        def pre_carriage_tenant_vehicle
          @pre_carriage_tenant_vehicle ||= tender.pickup_tenant_vehicle
        end

        def on_carriage_tenant_vehicle
          @on_carriage_tenant_vehicle ||= tender.delivery_tenant_vehicle
        end

        def transit_time
          (schedule.eta.to_date - schedule.etd.to_date).to_i
        end

        def valid_until
          tender.valid_until
        end

        def chargeable_weight
          has_cargo_chargeable_weight = shipment.meta.dig("cargo_chargeable_weight", tender.id).present?
          return shipment.meta.dig("cargo_chargeable_weight", tender.id) if has_cargo_chargeable_weight
          return "" if offer.blank?

          weight = offer.section(key: "cargo").first.fee.measures.kg.value
          update_shipment_meta(key: "cargo_chargeable_weight", value: weight)
          weight
        end

        def set_schedules_result
          return shipment.meta.dig("schedule_ids", tender.id) if shipment.meta.dig("schedule_ids", tender.id).present?
          return [] if offer.blank?

          trip_ids = offer.schedules.map(&:trip_id)
          update_shipment_meta(key: "schedule_ids", value: trip_ids)
        end

        def remark_notes
          Notes::Service.new(tender: tender, remarks: true).fetch.entries.pluck(:body)
        end
      end
    end
  end
end
