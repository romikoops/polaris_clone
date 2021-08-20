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
      FactoryBot.create(:routing_carrier, code: tenant_vehicle.carrier.code)
      allow(service).to receive(:geo_id_from_hub).and_return("XXX")
    end

    it "returns a valid RouteSection", :aggregate_failures do
      expect(service.route_section.transshipment).to eq(itinerary.transshipment)
    end
  end
end
