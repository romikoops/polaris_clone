# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::Routing::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:address) { FactoryBot.create(:legacy_address, organization: organization) }
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:offer) do
    OfferCalculator::Service::OfferCreators::Offer.new(
      request: request,
      schedules: [],
      offer: {cargo: []}
    )
  end
  let(:service) { described_class.new(request: request, offer: offer, section: "cargo") }

  describe "#route_point" do
    before do
      allow(service).to receive(:geo_id_from_hub).and_return("XXX")
    end

    let(:route_point) { service.route_point(location: hub) }

    context "when the RoutePoint doesnt exist" do
      it "returns a valid RoutePoint" do
        expect(route_point.locode).to eq(hub.hub_code)
      end
    end
  end
end
