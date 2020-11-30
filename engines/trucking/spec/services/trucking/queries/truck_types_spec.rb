# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucking::Queries::TruckTypes do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:distance_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: "Distance", organization: organization) }
  let(:zipcode_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: "Zipcode", organization: organization) }
  let(:location_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: "Location", organization: organization) }

  let(:trucking_location_zipcode) {
    FactoryBot.create(:trucking_location, :zipcode, country: country, data: zipcode)
  }
  let(:trucking_location_geometry) {
    FactoryBot.create(:trucking_location, :with_location, location: locations_location, country: country)
  }
  let(:trucking_location_distance) {
    FactoryBot.create(:trucking_location, :distance, country: country, data: distance)
  }
  let(:locations_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: latitude.to_f, lng: longitude.to_f),
      country_code: country_code)
  end

  let(:zipcode) { "15211" }
  let(:latitude) { "57.000000" }
  let(:longitude) { "11.100000" }
  let(:load_type) { "cargo_item" }
  let(:carriage) { "pre" }
  let(:distance) { 179 }
  let(:country_code) { "SE" }
  let(:country) { FactoryBot.create(:legacy_country, code: country_code) }

  let(:address) do
    FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
  end

  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:groups) { [default_group] }
  let(:service) do
    described_class.new(
      klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
      carriage: carriage, country_code: country_code, groups: groups,
      address: address, cargo_classes: ["lcl"], order_by: "group_id"
    )
  end

  before do
    %i[distance location zipcode].each do |query_method|
      FactoryBot.create(:trucking_hub_availability,
        hub: distance_hub,
        type_availability: FactoryBot.create(:trucking_type_availability, query_method: query_method))
    end
  end

  describe ".perform" do
    context "when finding hubs from truckings" do
      before do
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: zipcode_hub,
          location: trucking_location_zipcode)
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: location_hub,
          location: trucking_location_geometry)
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: distance_hub,
          location: trucking_location_distance)
        allow(service).to receive(:calc_distance).and_return(55)
      end

      let(:truck_types) { service.perform }

      it "return the truck types available for the given address" do
        expect(truck_types).to match_array(["default"])
      end
    end
  end
end
