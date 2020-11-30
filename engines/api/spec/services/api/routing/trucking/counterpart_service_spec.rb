# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::Trucking::CounterpartService, type: :service do
  include_context "complete_route_with_trucking"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:cargo_classes) { ["lcl"] }
  let(:load_type) { "cargo_item" }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:wrong_lat) { 10.00 }
  let(:wrong_lng) { 60.50 }
  let(:group_client) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:group) {
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: group_client, group: tapped_group)
    end
  }
  let(:args) {
    {coordinates: {lat: lat, lng: lng}, load_type: "cargo_item", organization: organization, target: target}
  }
  let(:coordinates) { {lat: lat, lng: lng} }
  let(:coordinate_trucking_details) {
    Api::Routing::Trucking::DetailsService.new(coordinates: coordinates, nexus_id: nil, load_type: "cargo_item")
  }
  let(:destination_nexus_trucking_details) {
    Api::Routing::Trucking::DetailsService.new(coordinates: nil,
                                               nexus_id: destination_hub.nexus_id, load_type: "cargo_item")
  }
  let(:origin_nexus_trucking_details) {
    Api::Routing::Trucking::DetailsService.new(coordinates: nil, nexus_id: origin_hub.nexus_id, load_type: "cargo_item")
  }
  let(:default_args) { {organization: organization, target: target} }
  let(:group_client) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:group) {
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: group_client, group: tapped_group)
    end
  }

  before do
    Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Helsingborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43822"
    ])
  end

  context "when not limited to groups" do
    describe ".counterpart_availabilities (origin)" do
      let(:lat) { pickup_address.latitude }
      let(:lng) { pickup_address.longitude }
      let(:target) { :origin }

      context "when trucking is available with lat lng args" do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options and country codes" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to match_array([trucking_availbilities.second.truck_type])
            expect(data[:countryCodes]).to eq(["cn"])
          end
        end
      end

      context "when trucking is available with nexus_id args" do
        let(:args) { default_args.merge(trucking_details: origin_nexus_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options and country codes" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to match_array([trucking_availbilities.second.truck_type])
            expect(data[:countryCodes]).to eq(["cn"])
          end
        end
      end
    end

    describe ".counterpart_availabilities (dest)" do
      let(:lat) { delivery_address.latitude }
      let(:lng) { delivery_address.longitude }
      let(:target) { :destination }

      context "when trucking is available with lat lng args" do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([trucking_availbilities.first.truck_type])
            expect(data[:countryCodes]).to eq(["se"])
          end
        end
      end

      context "when trucking is available with nexus_id args" do
        let(:args) { default_args.merge(trucking_details: destination_nexus_trucking_details) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options and country codes" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([trucking_availbilities.first.truck_type])
            expect(data[:countryCodes]).to eq(["se"])
          end
        end
      end
    end
  end

  context "when limited by groups" do
    before do
      Trucking::Trucking.update_all(group_id: group.id)
    end

    describe ".counterpart_availabilities (dest)" do
      let(:lat) { delivery_address.latitude }
      let(:lng) { delivery_address.longitude }
      let(:target) { :destination }

      context "when trucking is available for a group" do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([trucking_availbilities.first.truck_type])
          end
        end
      end

      context "when trucking is not available for a group" do
        let(:no_group_client) { FactoryBot.create(:organizations_user, organization: organization) }
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: no_group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq false
          end
        end
      end
    end

    describe ".counterpart_availabilities (origin)" do
      let(:lat) { pickup_address.latitude }
      let(:lng) { pickup_address.longitude }
      let(:target) { :origin }

      context "when trucking is available for a group" do
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq true
            expect(data[:truckTypes]).to eq([trucking_availbilities.second.truck_type])
          end
        end
      end

      context "when trucking is not available for a group" do
        let(:no_group_client) { FactoryBot.create(:organizations_user, organization: organization) }
        let(:args) { default_args.merge(trucking_details: coordinate_trucking_details, user: no_group_client) }
        let!(:data) { described_class.counterpart_availabilities(args) }

        it "returns available trucking options" do
          aggregate_failures do
            expect(data[:truckingAvailable]).to eq false
          end
        end
      end
    end
  end
end
