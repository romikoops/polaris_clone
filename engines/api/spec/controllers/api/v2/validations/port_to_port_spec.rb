# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ValidationsController, type: :controller do
    routes { Engine.routes }
    include_context "complete_route_with_trucking"
    let(:app) { FactoryBot.create(:application) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:token_header) { "Bearer #{FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: 'public').token}" }
    let(:origin) do
      FactoryBot.build(:carta_result,
        id: "xxx1",
        type: "locode",
        address: origin_hub.hub_code,
        latitude: origin_hub.latitude,
        longitude: origin_hub.longitude)
    end
    let(:destination) do
      FactoryBot.build(:carta_result,
        id: "xxx2",
        type: "locode",
        address: destination_hub.hub_code,
        latitude: destination_hub.latitude,
        longitude: destination_hub.longitude)
    end
    let(:cargo_classes) { ["fcl_20"] }
    let(:load_type) { "container" }
    let(:params) do
      {
        items: items,
        loadType: "container",
        types: ["cargo_item"],
        originId: origin.id,
        destinationId: destination.id,
        organization_id: organization.id
      }
    end
    let(:containers_attributes) do
      [
        {
          id: cargo_item_id,
          weight: 1200,
          width: nil,
          length: nil,
          height: nil,
          quantity: 1,
          cargoClass: "fcl_20",
          colliType: nil,
          stackable: true
        }
      ]
    end
    let(:invalid_containers_attributes) do
      [
        {
          id: cargo_item_id,
          weight: 12_000_000,
          width: nil,
          length: nil,
          height: nil,
          quantity: 1,
          cargoClass: "fcl_20",
          colliType: nil,
          stackable: true
        }
      ]
    end
    let(:cargo_item_id) { SecureRandom.uuid }

    before do
      FactoryBot.create(:legacy_max_dimensions_bundle,
        organization: organization,
        mode_of_transport: "ocean",
        payload_in_kg: 10_000,
        cargo_class: "fcl_20")
      FactoryBot.create(:fcl_20_pricing, organization: organization)
      allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
      allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
      allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin)
      allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(destination)
    end

    describe "post #create" do
      context "when port to port complete request (invalid cargo)" do
        let(:items) { invalid_containers_attributes }
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "message" => "Weight exceeds the limit of 10000 kg",
              "limit" => "10000 kg",
              "attribute" => "weight",
              "code" => 4001
            }
          ]
        end

        before do
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it "returns an array of expected errors" do
          expect(response_data.pluck("attributes")).to eq(expected_errors)
        end
      end
    end
  end
end
