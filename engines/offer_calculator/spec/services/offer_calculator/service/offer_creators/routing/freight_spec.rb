# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::Routing::Freight do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:address) { FactoryBot.create(:legacy_address, organization: organization) }
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:offer) do
    OfferCalculator::Service::OfferCreators::Offer.new(
      request: request,
      schedules: [],
      offer: { cargo: [] }
    )
  end
  let(:service) { described_class.new(request: request, offer: offer, section: "cargo") }

  describe "#route_section" do
    before do
      allow(offer).to receive(:itinerary).and_return(itinerary)
      allow(offer).to receive(:tenant_vehicle).and_return(tenant_vehicle)
      allow(service).to receive(:geo_id_from_hub).and_return("XXX")
    end

    context "when Routing::Carrier exists" do
      before { FactoryBot.create(:routing_carrier, code: tenant_vehicle.carrier.code) }

      it "returns the RouteSection with the correct transshipment" do
        expect(service.route_section.transshipment).to eq(itinerary.transshipment)
      end

      it "sets the transit_time as nil, when no Legacy::TransitTime exists" do
        expect(service.route_section.transit_time).to be_nil
      end

      context "with Legacy::TransitTime" do
        let!(:transit_time) { FactoryBot.create(:legacy_transit_time, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }

        it "sets the transit_time when Legacy::TransitTime exists" do
          expect(service.route_section.transit_time).to eq(transit_time.duration)
        end
      end
    end

    context "when the Routing Carrier doesnt exist" do
      it "raises an OfferBuilder error" do
        expect { service.route_section }.to raise_error(OfferCalculator::Errors::OfferBuilder)
      end
    end
  end
end
