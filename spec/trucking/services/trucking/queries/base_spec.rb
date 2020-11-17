# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucking::Queries::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:hub) { FactoryBot.create(:legacy_hub, :hamburg, :with_lat_lng, organization: organization) }
  let(:location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: hub.latitude, lng: hub.longitude, delta: 0.4),
      country_code: "de")
  end
  let(:trucking_location) { FactoryBot.create(:trucking_location, location: location, country_code: "DE") }

  before do
    stub_request(:get, "https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=now&destination=57.694253,11.854048&key=FAKEKEY&language=en&mode=driving&origin=57.694253,11.854048&traffic_model=pessimistic").
      to_return(status: 200)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: hub, query_type: :distance)
    FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: hub, location: trucking_location)
  end

  describe ".distance_hubs" do
    it "with proper args returns an array of hub ids with distance" do
      address = OpenStruct.new(latitude: hub.latitude.to_f, longitude: hub.longitude.to_f, lat_lng_string: [hub.latitude, hub.longitude].join(","), get_zip_code: nil, city_name: hub.name, country: OpenStruct.new(code: hub.country.code))
      result = described_class.new(organization_id: organization.id, carriage: "pre", address: address, order_by: "group_id", hub_ids: [hub.id], load_type: "cargo_item").distances_with_hubs
      expect(result).to eq([{hub_id: hub.id, distance: 0}])
    end
  end
end
