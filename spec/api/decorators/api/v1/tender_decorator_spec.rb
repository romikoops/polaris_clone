# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::TenderDecorator do
  let(:charge_category) { FactoryBot.create(:bas_charge) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, trip: trip) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Maersk", code: "maersk") }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
  let(:truck_type) { "default" }
  let(:tender) do
    FactoryBot.create(:quotations_tender,
      itinerary: itinerary,
      charge_breakdown: charge_breakdown,
      origin_hub: itinerary.origin_hub,
      destination_hub: itinerary.destination_hub,
      tenant_vehicle: tenant_vehicle,
      pickup_tenant_vehicle: tenant_vehicle,
      delivery_tenant_vehicle: tenant_vehicle,
      pickup_truck_type: truck_type,
      delivery_truck_type: truck_type,
      transshipment: itinerary.transshipment)
  end
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_tender) { described_class.new(tender, context: {scope: scope}) }

  before do
    FactoryBot.create(:quotations_line_item, charge_category: charge_category)
  end

  describe ".decorate" do
    it "decorates the tender with route, vessel and transit times" do
      aggregate_failures do
        expect(decorated_tender.route).to eq(itinerary.name)
        expect(decorated_tender.transit_time).to eq((trip.end_date.to_date - trip.start_date.to_date).to_i)
        expect(decorated_tender.vessel).to eq(trip.vessel)
        expect(decorated_tender.charges.length).to eq(tender.line_items.count + 1)
      end
    end
  end

  describe "pickup_carrier" do
    it "returns carrier name" do
      aggregate_failures do
        expect(decorated_tender.pickup_carrier).to eq(carrier.name)
      end
    end
  end

  describe "pickup_service" do
    it "returns service name" do
      aggregate_failures do
        expect(decorated_tender.pickup_service).to eq(tenant_vehicle.name)
      end
    end
  end

  describe "delivery_carrier" do
    it "returns carrier name" do
      aggregate_failures do
        expect(decorated_tender.delivery_carrier).to eq(carrier.name)
      end
    end
  end

  describe "delivery_service" do
    it "returns service name" do
      aggregate_failures do
        expect(decorated_tender.delivery_service).to eq(tenant_vehicle.name)
      end
    end
  end
end
