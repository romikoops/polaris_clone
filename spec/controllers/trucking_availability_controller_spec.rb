# frozen_string_literal: true

require "rails_helper"

RSpec.describe TruckingAvailabilityController, type: :controller do
  include_context "complete_route_with_trucking"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:wrong_lat) { 10.00 }
  let(:wrong_lng) { 60.50 }
  let(:hub_ids) { origin_hub.id.to_s }
  let(:cargo_classes) { ["lcl"] }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:response_body) { JSON.parse(response.body) }
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:group_id) { default_group.id }
  let(:data) { response_body["data"] }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
    Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Helsingborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43822"
    ])
  end

  describe "GET #index" do
    let(:lat) { pickup_address.latitude }
    let(:lng) { pickup_address.longitude }
    let(:load_type) { "cargo_item" }
    let(:params) do
      {
        lat: lat, lng: lng, load_type: load_type, organization_id: organization.id,
        carriage: "pre", hub_ids: hub_ids
      }
    end

    shared_examples_for "TruckingAvailability#index trucking is found" do
      it "returns available trucking options", :aggregate_failures do
        get :index, params: params, as: :json
        expect(data["truckingAvailable"]).to eq true
        expect(data["truckTypeObject"]).to eq({ origin_hub.id.to_s => ["default"] })
        expect(data["nexusIds"]).to eq([origin_hub.nexus_id])
        expect(data["hubIds"]).to eq([origin_hub.id])
      end
    end

    context "when trucking is available" do
      it_behaves_like "TruckingAvailability#index trucking is found"
    end

    context "when trucking is available and user is guest" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it_behaves_like "TruckingAvailability#index trucking is found"
    end

    context "when trucking is available and only group truckings are present" do
      let(:group_id) { group.id }

      it_behaves_like "TruckingAvailability#index trucking is found"
    end

    context "when trucking is not available" do
      let(:lat) { wrong_lat }
      let(:lng) { wrong_lng }
      let(:load_type) { "container" }

      before do
        get :index, params: params, as: :json
      end

      it "returns empty keys when no trucking is available", :aggregate_failures do
        expect(data["truckingAvailable"]).to eq false
        expect(data["truckTypeObject"]).to be_empty
        expect(data["nexusIds"]).to be_empty
        expect(data["hubIds"]).to be_empty
      end
    end
  end
end
