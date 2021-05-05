# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucking::Queries::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:hub) { FactoryBot.create(:hamburg_hub, :hamburg, organization: organization) }
  let(:location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: hub.latitude, lng: hub.longitude, delta: 0.4),
      country_code: "de")
  end
  let(:trucking_location) { FactoryBot.create(:trucking_location, query: :location, location: location, country_code: "DE") }
  let(:address) { FactoryBot.create(:hamburg_address) }
  let(:stub_url) do
    [
      "https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=now&destination=",
      [hub.latitude, hub.longitude].join(","),
      "&key=#{Settings.google&.api_key}&language=en&mode=driving&origin=",
      [address.latitude, address.longitude].join(","),
      "&traffic_model=pessimistic"
    ].join
  end

  before do
    stub_request(:get, stub_url)
      .to_return(status: 200)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: hub, query_type: :distance)
    FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: hub, location: trucking_location)
  end

  describe ".distance_hubs" do
    let(:result) do
      described_class.new(
        organization_id: organization.id,
        carriage: "pre",
        address: address,
        order_by: "group_id",
        hub_ids: [hub.id],
        load_type: "cargo_item"
      ).distances_with_hubs
    end

    it "with proper args returns an array of hub ids with distance" do
      expect(result).to eq([{ hub_id: hub.id, distance: 0 }])
    end
  end
end
