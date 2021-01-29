# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::Trucking::AvailabilityService, type: :service do
  include_context "complete_route_with_trucking"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:cargo_classes) { ["lcl"] }
  let(:load_type) { "cargo_item" }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:wrong_lat) { 10.00 }
  let(:wrong_lng) { 60.50 }
  let(:group_client) { FactoryBot.create(:users_client, organization: organization) }
  let(:group) {
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: group_client, group: tapped_group)
    end
  }
  let(:args) {
    {coordinates: {lat: lat, lng: lng}, load_type: "cargo_item", organization: organization, target: target}
  }

  before do
    FactoryBot.create(:trucking_trucking, organization: organization, hub: destination_hub, carriage: "on",
                                          location: delivery_trucking_location, truck_type: "group", group_id: group.id)
    Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Helsingborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43822"
    ])
  end

  describe ".availability (origin)" do
    let(:lat) { pickup_address.latitude }
    let(:lng) { pickup_address.longitude }
    let(:target) { :origin }

    context "when trucking is available" do
      let!(:data) { described_class.availability(args) }

      it "returns available trucking options" do
        aggregate_failures do
          expect(data[:truckingAvailable]).to eq true
          expect(data[:truckTypes]).to eq([trucking_availbilities.first.truck_type])
        end
      end
    end

    context "when trucking is not available" do
      let(:args) {
        {coordinates: {lat: wrong_lat, lng: wrong_lng}, load_type: "container", organization: organization,
         target: target}
      }
      let!(:data) { described_class.availability(args) }

      it "returns empty keys when no trucking is available" do
        aggregate_failures do
          expect(data[:truckingAvailable]).to eq false
          expect(data[:truckTypes]).to be_empty
        end
      end
    end
  end

  describe ".availability (destination)" do
    let(:lat) { delivery_address.latitude }
    let(:lng) { delivery_address.longitude }
    let(:target) { :destination }

    context "when trucking is available" do
      let!(:data) { described_class.availability(args) }

      it "returns available trucking options" do
        aggregate_failures do
          expect(data[:truckingAvailable]).to eq true
          expect(data[:truckTypes]).to eq([trucking_availbilities.second.truck_type])
        end
      end
    end

    context "when trucking is not available" do
      let(:args) {
        {coordinates: {lat: wrong_lat, lng: wrong_lng}, load_type: "container",
         organization: organization, target: :destination}
      }
      let!(:data) { described_class.availability(args) }

      it "returns empty keys when no trucking is available" do
        aggregate_failures do
          expect(data[:truckingAvailable]).to eq false
          expect(data[:truckTypes]).to be_empty
        end
      end
    end

    context "when trucking is available for a group" do
      let(:group_args) {
        {coordinates: {lat: lat, lng: lng}, load_type: "cargo_item",
         organization: organization, target: target, user: group_client}
      }
      let!(:data) { described_class.availability(group_args) }

      it "returns available trucking options" do
        aggregate_failures do
          expect(data[:truckingAvailable]).to eq true
          expect(data[:truckTypes]).to include("group")
        end
      end
    end

    context "when trucking is not available for a group" do
      let(:no_group_client) {
        FactoryBot.create(:users_client, organization: organization)
      }
      let(:no_group_args) {
        {coordinates: {lat: lat, lng: lng}, load_type: "cargo_item",
         organization: organization, target: target, user: no_group_client}
      }
      let!(:data) { described_class.availability(no_group_args) }

      it "returns available trucking options" do
        aggregate_failures do
          expect(data[:truckingAvailable]).to eq true
          expect(data[:truckTypes]).not_to include("group")
        end
      end
    end
  end
end
