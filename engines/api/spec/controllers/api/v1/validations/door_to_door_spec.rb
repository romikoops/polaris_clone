# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ValidationsController, type: :controller do
    routes { Engine.routes }
    include_context "complete_route_with_trucking"
    let(:app) { FactoryBot.create(:application) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user) }
    let(:client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:load_type) { "cargo_item" }
    let(:cargo_classes) { ["lcl"] }
    let(:shipping_info) { { trucking_info: { pre_carriage: :pre } } }
    let(:params) do
      {
        redirect_uri: app.redirect_uri,
        organization_id: organization.id,
        quote: {
          organization_id: organization.id,
          user_id: client.id,
          load_type: load_type,
          origin: origin,
          destination: destination
        },
        shipment_info: shipping_info
      }
    end
    let(:cargo_items_attributes) do
      [
        {
          "id" => SecureRandom.uuid,
          "payload_in_kg" => 120,
          "total_volume" => 0,
          "total_weight" => 0,
          "width" => 120,
          "length" => 80,
          "height" => 120,
          "quantity" => 1,
          "dangerous_goods" => false,
          "stackable" => true
        }
      ]
    end
    let(:invalid_cargo_items_attributes) do
      [
        {
          "id" => cargo_item_id,
          "payload_in_kg" => 120,
          "total_volume" => 0,
          "total_weight" => 0,
          "width" => 120,
          "length" => 80,
          "height" => 1200,
          "quantity" => 1,
          "dangerous_goods" => false,
          "stackable" => true
        }
      ]
    end
    let(:origin) { { latitude: pickup_address.latitude, longitude: pickup_address.longitude } }
    let(:destination) { { latitude: delivery_address.latitude, longitude: delivery_address.longitude } }
    let(:cargo_item_id) { SecureRandom.uuid }

    before { FactoryBot.create(:users_membership, organization: organization, user: user) }

    shared_examples_for "Expected errors are returned" do
      it "returns an array of expected errors" do
        expect(response_data.pluck("attributes")).to eq(expected_errors)
      end
    end

    describe "post #create" do
      let(:origin_carta_result) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
      let(:destination_carta_result) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }

      before do
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: pickup_address.latitude, longitude: pickup_address.longitude).and_return(origin_carta_result)
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: delivery_address.latitude, longitude: delivery_address.longitude).and_return(destination_carta_result)
      end

      context "when door to door complete request (no pricings)" do
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            "id" => "routing",
            "limit" => nil,
            "message" => "No Pricings are available for your route",
            "attribute" => "routing",
            "section" => "routing",
            "code" => 4008
          }]
        end
        let!(:pricings) do
          [FactoryBot.create(:pricings_pricing, organization: organization)]
        end

        before do
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when door to door complete request (no group pricings)" do
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            "id" => "routing",
            "limit" => nil,
            "message" => "No Pricings are available for your groups",
            "attribute" => "routing",
            "section" => "routing",
            "code" => 4009
          }]
        end

        before do
          organization.scope.update(content: { dedicated_pricings_only: true })
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when door to door complete request (invalid cargo)" do
        let(:cargo_items_attributes) { invalid_cargo_items_attributes }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "message" => "Height exceeds the limit of 5 m",
              "limit" => "5 m",
              "attribute" => "height",
              "section" => "cargo_item",
              "code" => 4002
            },
            {
              "id" => cargo_item_id,
              "limit" => "Chargeable Weight Exceeded",
              "message" => "Chargeable Weight exceeds the limit of 10000 kg",
              "attribute" => "chargeable_weight",
              "section" => "cargo_item",
              "code" => 4005
            }
          ]
        end

        before do
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when door to door complete request (invalid cargo  & multiple mots)" do
        let(:cargo_items_attributes) { invalid_cargo_items_attributes }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "limit" => "5 m",
              "message" => "Height exceeds the limit of 5 m",
              "attribute" => "height",
              "section" => "cargo_item",
              "code" => 4002
            },
            {
              "attribute" => "chargeable_weight",
              "code" => 4005,
              "id" => cargo_item_id,
              "limit" => "Chargeable Weight Exceeded",
              "message" => "Chargeable Weight exceeds the limit of 10000 kg",
              "section" => "cargo_item"
            }
          ]
        end
        let(:air_itinerary) do
          FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: "air", organization: organization)
        end
        let(:origin_airport) { air_itinerary.origin_hub }
        let(:destination_airport) { air_itinerary.destination_hub }

        before do
          FactoryBot.create(:trucking_hub_availability,
            hub: origin_airport, type_availability: trucking_availbilities.first.type_availability)
          FactoryBot.create(:trucking_hub_availability,
            hub: destination_airport, type_availability: trucking_availbilities.last.type_availability)
          FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: origin_airport,
                                                location: pickup_trucking_location)
          FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: destination_airport,
                                                carriage: "on", location: delivery_trucking_location)
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          request.headers["Authorization"] = token_header

          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end
    end
  end
end
