# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ValidationsController, type: :controller do
    routes { Engine.routes }
    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:organizations_user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:origin_nexus) { FactoryBot.create(:legacy_nexus, organization: organization) }
    let(:destination_nexus) { FactoryBot.create(:legacy_nexus, organization: organization) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
    let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "quickly") }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: organizations_user.id) }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:shipping_info) { { trucking_info: { pre_carriage: :pre } } }
    let(:cargo_item_id) { SecureRandom.uuid }
    let(:load_type) { "cargo_item" }
    let(:group) do
      FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
        FactoryBot.create(:groups_membership, group: tapped_group, member: user)
      end
    end
    let(:params) do
      {
        organization_id: organization.id,
        quote: {
          organization_id: organization.id,
          user_id: user.id,
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
          "id" => cargo_item_id,
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
    let(:origin) { { nexus_id: origin_hub.nexus_id } }
    let(:destination) { { nexus_id: destination_hub.nexus_id } }

    before do
      ::Organizations.current_id = user.organization_id
    end

    shared_examples_for "Expected errors are returned" do
      it "returns an array of expected errors" do
        expect(response_data.pluck("attributes")).to eq(expected_errors)
      end
    end

    describe "post #create" do
      context "when port to port complete request (no pricings)" do
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            "id" => "routing",
            "message" => "No Pricings are available for your route",
            "attribute" => "routing",
            "limit" => nil,
            "section" => "routing",
            "code" => 4008
          }]
        end

        before do
          request.headers["Authorization"] = token_header
          FactoryBot.create(:fcl_20_pricing, organization: organization)
          post :create, params: params
        end

        it_behaves_like  "Expected errors are returned"
      end

      context "when port to port complete request (no group pricings)" do
        let(:origin) { { nexus_id: origin_hub.nexus_id } }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            "id" => "routing",
            "message" => "No Pricings are available for your groups",
            "attribute" => "routing",
            "limit" => nil,
            "section" => "routing",
            "code" => 4009
          }]
        end

        before do
          organization.scope.update(content: { dedicated_pricings_only: true })
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when port to port complete request (invalid cargo)" do
        let(:cargo_items_attributes) { invalid_cargo_items_attributes }
        let(:origin) { { nexus_id: origin_hub.nexus_id } }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
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
              "message" => "Chargeable Weight exceeds the limit of 10000 kg",
              "limit" => "Chargeable Weight Exceeded",
              "attribute" => "chargeable_weight",
              "section" => "cargo_item",
              "code" => 4005
            }
          ]
        end

        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like  "Expected errors are returned"
      end

      context "with dedicated pricings" do
        let(:origin) { { nexus_id: origin_hub.nexus_id } }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }

        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary, group: group)
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it "returns an array of one error" do
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data).to be_empty
          end
        end
      end

      context "when port to port request (no routing &invalid cargo)" do
        let(:cargo_items_attributes) do
          [
            {
              "id" => cargo_item_id,
              "payload_in_kg" => 12_000,
              "total_volume" => 0,
              "total_weight" => 0,
              "width" => 120,
              "length" => 80,
              "height" => 100,
              "quantity" => 1,
              "dangerous_goods" => false,
              "stackable" => true
            }
          ]
        end
        let(:origin) { {} }
        let(:destination) { {} }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "message" => "Weight exceeds the limit of 10000 kg",
              "limit" => "10000 kg",
              "attribute" => "payload_in_kg",
              "section" => "cargo_item",
              "code" => 4001
            },
            {
              "id" => cargo_item_id,
              "message" => "Chargeable Weight exceeds the limit of 10000 kg",
              "limit" => "Chargeable Weight Exceeded",
              "attribute" => "chargeable_weight",
              "section" => "cargo_item",
              "code" => 4005
            }
          ]
        end

        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when port to port complete request (invalid fcl cargo)" do
        let(:containers_attributes) do
          [
            {
              "id" => cargo_item_id,
              "payload_in_kg" => 999_999,
              "total_volume" => 0,
              "total_weight" => 0,
              "width" => 0,
              "length" => 0,
              "height" => 0,
              "quantity" => 1,
              "dangerous_goods" => false,
              "size_class" => "fcl_20"
            }
          ]
        end
        let(:origin) { { nexus_id: origin_hub.nexus_id } }
        let(:load_type) { "container" }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
        let(:shipping_info) { { containers_attributes: containers_attributes } }
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "message" => "Weight exceeds the limit of 10000 kg",
              "limit" => "10000 kg",
              "attribute" => "payload_in_kg",
              "section" => "cargo_item",
              "code" => 4001
            }
          ]
        end

        before do
          FactoryBot.create(:legacy_max_dimensions_bundle,
            organization: organization,
            mode_of_transport: "ocean",
            payload_in_kg: 10_000,
            cargo_class: "fcl_20")
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
          request.headers["Authorization"] = token_header
          post :create, params: params
        end

        it_behaves_like "Expected errors are returned"
      end
    end
  end
end
