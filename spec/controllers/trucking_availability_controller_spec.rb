# frozen_string_literal: true

require "rails_helper"

RSpec.describe TruckingAvailabilityController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:user) { FactoryBot.create(:authentication_user, :organizations_user, organization_id: organization.id) }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
      country_code: "se")
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: destination_hub.latitude, lng: destination_hub.longitude,
                                               delta: 0.4),
      country_code: "cn")
  end
  let(:origin_trucking_location) {
    FactoryBot.create(:trucking_location, location: origin_location, country_code: "SE")
  }
  let(:destination_trucking_location) {
    FactoryBot.create(:trucking_location, location: destination_location, country_code: "CN")
  }
  let(:wrong_lat) { 10.00 }
  let(:wrong_lng) { 60.50 }
  let(:hub_ids) { origin_hub.id.to_s }
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
    FactoryBot.create(:organizations_scope, target: organization, content: {base_pricing: true})
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
    FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: origin_hub,
      location: origin_trucking_location,
      group_id: group_id)
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: destination_hub,
      carriage: "on",
      location: destination_trucking_location,
      group_id: group_id)
    Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Helsingborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43822"
    ])
    Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Göteborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43813"
    ])
    Geocoder::Lookup::Test.add_stub([destination_hub.latitude, destination_hub.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Shanghai, China",
      "city" => "Shanghai",
      "country" => "China",
      "country_code" => "CN",
      "postal_code" => "210001"
    ])
  end

  describe "GET #index" do
    let(:lat) { origin_hub.latitude }
    let(:lng) { origin_hub.longitude }

    context "when trucking is available" do
      before do
        params = {
          lat: lat, lng: lng, load_type: "cargo_item", organization_id: organization.id,
          carriage: "pre", hub_ids: hub_ids
        }
        get :index, params: params, as: :json
      end

      it "returns available trucking options" do
        aggregate_failures do
          expect(response).to be_successful
          expect(data["truckingAvailable"]).to eq true
          expect(data["truckTypeObject"]).to eq({origin_hub.id.to_s => ["default"]})
          expect(data["nexusIds"]).to eq([origin_hub.nexus_id])
          expect(data["hubIds"]).to eq([origin_hub.id])
        end
      end
    end

    context "when trucking is available and user is guest" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        params = {
          lat: lat, lng: lng, load_type: "cargo_item", organization_id: organization.id,
          carriage: "pre", hub_ids: hub_ids
        }
        get :index, params: params, as: :json
      end

      it "returns available trucking options" do
        aggregate_failures do
          expect(response).to be_successful
          expect(data["truckingAvailable"]).to eq true
          expect(data["truckTypeObject"]).to eq({origin_hub.id.to_s => ["default"]})
          expect(data["nexusIds"]).to eq([origin_hub.nexus_id])
          expect(data["hubIds"]).to eq([origin_hub.id])
        end
      end
    end

    context "when trucking is available and only group truckings are present" do
      let(:group_id) { group.id }

      before do
        params = {
          lat: lat, lng: lng, load_type: "cargo_item", organization_id: organization.id,
          carriage: "pre", hub_ids: hub_ids
        }
        get :index, params: params, as: :json
      end

      it "returns available trucking options" do
        aggregate_failures do
          expect(response).to be_successful
          expect(data["truckingAvailable"]).to eq true
          expect(data["truckTypeObject"]).to eq({origin_hub.id.to_s => ["default"]})
          expect(data["nexusIds"]).to eq([origin_hub.nexus_id])
          expect(data["hubIds"]).to eq([origin_hub.id])
        end
      end
    end

    context "when trucking is not available" do
      before do
        params = {
          lat: wrong_lat, lng: wrong_lng, load_type: "container",
          organization_id: organization.id, carriage: "on", hub_ids: hub_ids
        }
        get :index, params: params, as: :json
      end

      it "returns empty keys when no trucking is available" do
        aggregate_failures do
          expect(response).to be_successful
          expect(data["truckingAvailable"]).to eq false
          expect(data["truckTypeObject"]).to be_empty
          expect(data["nexusIds"]).to be_empty
          expect(data["hubIds"]).to be_empty
        end
      end
    end
  end
end
