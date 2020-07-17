# frozen_string_literal: true

require "rails_helper"
require_relative "../../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreators::LegacyMeta do
  include_context "full_offer"
  let(:tender) { OfferCalculator::Service::OfferCreators::Tender.tender(offer: offer, shipment: shipment, quotation: quotation) }
  let(:scope) { {} }
  let(:meta) { described_class.meta(offer: offer, shipment: shipment, tender: tender, scope: scope) }
  let(:expected_keys) do
    %i[
      itinerary_id
      destination_hub
      charge_trip_id
      transit_time
      load_type
      mode_of_transport
      name
      service_level
      carrier_name
      origin_hub
      tenant_vehicle_id
      shipment_id
      ocean_chargeable_weight
      transshipmentVia
      validUntil
      remarkNotes
      pricing_rate_data
      pre_carriage_carrier
      on_carriage_carrier
      exchange_rates
      on_carriage_service
      on_carriage_truck_type
      pre_carriage_service
      pre_carriage_truck_type
    ]
  end

  context "when it returns a valid meta without rate data" do
    it "returns a valid meta without rate data" do
      aggregate_failures do
        expect(meta).to be_a(Hash)
        expect(meta.keys).to match_array(expected_keys)
        expect(meta[:pricing_rate_data]).to eq({})
      end
    end
  end

  context "when it returns a valid meta with rate data" do
    let(:scope) { {show_rate_overview: true} }

    it "returns a valid meta with rate data" do
      aggregate_failures do
        expect(meta).to be_a(Hash)
        expect(meta.keys).to match_array(expected_keys)
        expect(meta[:pricing_rate_data].keys).to eq(shipment.cargo_classes)
      end
    end
  end
end
