# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::Routing::LocationAsRoutePoint do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:service) { described_class.new(request: request, location: location) }
  let(:route_point) { service.perform }
  let(:location) { FactoryBot.create(:legacy_hub, organization: organization) }

  describe "#perform" do
    context "when the provided location is a Legacy::Hub" do
      before do
        allow(Carta::Client).to receive(:suggest).with(query: location.nexus.locode).and_return(
          instance_double(Carta::Result, id: "XXX")
        )
      end

      it "returns a RoutePoint with the hub's related LOCODE" do
        expect(route_point.locode).to eq(location.hub_code)
      end

      it "returns a RoutePoint with the hub's name" do
        expect(route_point.name).to eq(location.name)
      end

      it "returns a RoutePoint with the function 'port'" do
        expect(route_point.function).to eq("port")
      end

      it "returns a RoutePoint with the country of the Hub" do
        expect(route_point.country).to eq(location.nexus.country.code)
      end

      it "returns a RoutePoint with the coordinates of the Hub" do
        expect(route_point.coordinates).to eq(location.point)
      end

      it "returns a RoutePoint with the geo id returned from the method 'geo_id_from_hub'" do
        expect(route_point.geo_id).to eq("XXX")
      end
    end

    context "when the provided location is a Legacy::Address" do
      let(:location) { FactoryBot.create(:legacy_address) }

      it "returns a RoutePoint without LOCODE" do
        expect(route_point.locode).to be_nil
      end

      it "returns a RoutePoint with the addresses geocoded_address" do
        expect(route_point.name).to eq(location.geocoded_address)
      end

      it "returns a RoutePoint with the function 'address'" do
        expect(route_point.function).to eq("address")
      end

      it "returns a RoutePoint with the country of the Address" do
        expect(route_point.country).to eq(location.country.code)
      end

      it "returns a RoutePoint with the coordinates of the Address" do
        expect(route_point.coordinates).to eq(location.set_point)
      end

      context "when the Address is the pickup_address" do
        before do
          allow(request).to receive(:pickup_address).and_return(location)
          allow(request).to receive(:origin_geo_id).and_return("XXX")
        end

        it "returns a RoutePoint with the origin_geo_id" do
          expect(route_point.geo_id).to eq("XXX")
        end
      end

      context "when the Address is the delivery_address" do
        before do
          allow(request).to receive(:delivery_address).and_return(location)
          allow(request).to receive(:destination_geo_id).and_return("XXX")
        end

        it "returns a RoutePoint with the destination_geo_id" do
          expect(route_point.geo_id).to eq("XXX")
        end
      end
    end

    context "when location is not found in Carta" do
      before do
        allow(Carta::Client).to receive(:suggest).with(query: location.hub_code).and_raise(Carta::Client::LocationNotFound)
      end

      it "rescues the Carta error and raises the related OfferCalculator::Errors" do
        expect { route_point }.to raise_error(OfferCalculator::Errors::LocationNotFound)
      end
    end

    context "when Carta is unavailable" do
      before do
        allow(Carta::Client).to receive(:suggest).with(query: location.hub_code).and_raise(Carta::Client::ServiceUnavailable)
      end

      it "rescues the Carta error and raises the related OfferCalculator::Errors" do
        expect { route_point }.to raise_error(OfferCalculator::Errors::OfferBuilder)
      end
    end
  end
end
