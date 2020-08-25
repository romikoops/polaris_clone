# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::LegacyMeta do
  include_context "full_offer"

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

  context "with offer" do
    let(:tender) do
      OfferCalculator::Service::OfferCreators::Tender.tender(
        offer: offer, shipment: shipment, quotation: quotation
      )
    end

    before do
      OfferCalculator::Service::OfferCreators::LineItems.line_items(
        offer: offer, shipment: shipment, tender: tender
      )

      OfferCalculator::Service::OfferCreators::LegacyChargeBreakdown.charge_breakdown(
        offer: offer, shipment: shipment, tender: tender
      )
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

    context "when it returns a valid meta with tender rate data" do
      let(:scope) { {show_rate_overview: true} }

      before do
        shipment.meta["rate_overviews"] = {}
        shipment.meta["rate_overviews"][tender.id] = {data: "tender rate data"}
        shipment.save
      end

      it "returns a valid meta with rate data" do
        expect(meta[:pricing_rate_data]).to eq({"data" => "tender rate data"})
      end
    end
  end

  context "without offer" do
    let(:shipment) do
      FactoryBot.create(
        :completed_legacy_shipment,
        with_breakdown: true,
        with_tenders: true,
        organization_id: organization.id,
        user: user
      )
    end
    let(:tender) { shipment.charge_breakdowns.first.tender }
    let(:quotation) { Quotations::Quotation.find_by(legacy_shipment: shipment) }
    let(:offer) { nil }

    it "returns a valid meta without offer" do
      aggregate_failures do
        expect(meta).to be_a(Hash)
        expect(meta.keys).to match_array(expected_keys)
        expect(meta[:pricing_rate_data]).to eq({})
      end
    end
  end
end
