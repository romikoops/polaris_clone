# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::RouteSectionSerializer do
    let(:route_section) { FactoryBot.create(:journey_route_section, transshipment: "ZACPT", carrier: routing_carrier.name) }
    let(:decorated_route_section) { Api::V2::RouteSectionDecorator.new(route_section) }
    let(:serialized_route_section) { described_class.new(decorated_route_section).serializable_hash }
    let(:target) { serialized_route_section.dig(:data, :attributes) }
    let(:routing_carrier) { FactoryBot.create(:routing_carrier) }
    let(:expected_origin) do
      {
        "locode" => route_section.from.locode,
        "city" => route_section.from.city,
        "coordinates" => route_section.from.coordinates,
        "address" => route_section.from.name,
        "terminal" => route_section.from.terminal
      }
    end

    it "returns the correct data for the origin of the RouteSection for the object passed" do
      expect(target[:origin]).to eq(expected_origin)
    end

    it "returns the carrier logo" do
      expect(target[:carrierLogo]).to include(routing_carrier.logo.filename.to_s)
    end

    it "returns the transshipment" do
      expect(target[:transshipment]).to eq("ZACPT")
    end
  end
end
