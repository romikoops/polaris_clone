# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::RoutePointDecorator do
  let(:route_point) { FactoryBot.create(:journey_route_point) }
  let(:decorated_route_point) { described_class.new(route_point) }

  describe "#description" do
    context "when the RoutePoint has a locode" do
      it "returns a name with the locode in parentheses" do
        expect(decorated_route_point.description).to include("Hamburg (DEHAM)")
      end
    end

    context "when the RoutePoint does not have a locode present" do
      let(:route_point) { FactoryBot.create(:journey_route_point, locode: nil) }

      it "returns a the name alone" do
        expect(decorated_route_point.description).to eq(route_point.name)
      end
    end
  end

  describe "#latitude" do
    it "returns the latitude of the point" do
      expect(decorated_route_point.latitude).to eq(57.694253)
    end
  end

  describe "#longitude" do
    it "returns the longitude of the point" do
      expect(decorated_route_point.longitude).to eq(11.854048)
    end
  end
end
