# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ValidationsController, type: :controller do
    routes { Engine.routes }
    include_context "complete_route_with_trucking"
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:token_header) { "Bearer #{FactoryBot.create(:access_token, application: FactoryBot.create(:application), resource_owner_id: client.id, scopes: 'public').token}" }
    let(:origin) do
      FactoryBot.build(:carta_result,
        id: "xxx1",
        type: "address",
        address: pickup_address.geocoded_address,
        latitude: pickup_address.latitude,
        longitude: pickup_address.longitude)
    end
    let(:destination) do
      FactoryBot.build(:carta_result,
        id: "xxx2",
        type: "address",
        address: delivery_address.geocoded_address,
        latitude: delivery_address.latitude,
        longitude: delivery_address.longitude)
    end
    let(:cargo_classes) { ["lcl"] }
    let(:load_type) { "cargo_item" }
    let(:types) { ["cargo_item"] }
    let(:params) do
      {
        items: items,
        types: types,
        loadType: load_type,
        originId: origin.id,
        destinationId: destination.id,
        organization_id: organization.id
      }
    end
    let(:cargo_item_id) { SecureRandom.uuid }

    before do
      allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
      allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
      allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
      allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
        destination_hub.nexus
      )
      FactoryBot.create(:legacy_cargo_item_type)
    end

    shared_examples_for "Expected errors are returned" do
      it "returns an array of expected errors" do
        expect(response_data.pluck("attributes")).to match_array(expected_errors)
      end
    end

    describe "post #create" do
      let(:origin_carta_result) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
      let(:destination_carta_result) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }

      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: organization,
          mode_of_transport: "ocean",
          payload_in_kg: 10_000,
          aggregate: true,
          cargo_class: "lcl")
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: pickup_address.latitude, longitude: pickup_address.longitude).and_return(origin_carta_result)
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: delivery_address.latitude, longitude: delivery_address.longitude).and_return(destination_carta_result)
        request.headers["Authorization"] = token_header
        post :create, params: params
      end

      context "when the CargoUnit is valid" do
        let(:items) do
          [
            {
              id: cargo_item_id,
              weight: 1200,
              width: 120,
              length: 80,
              height: 120,
              quantity: 1,
              cargoClass: "lcl",
              colliType: "pallet",
              stackable: true
            }
          ]
        end

        it "returns an empty array" do
          expect(response_data).to be_empty
        end
      end

      context "when door to door complete request (invalid cargo)" do
        let(:items) do
          [
            {
              id: cargo_item_id,
              weight: 120,
              width: 120,
              length: 80,
              height: 1200,
              quantity: 1,
              dangerous_goods: false,
              cargoClass: "lcl",
              colliType: "pallet",
              stackable: true
            }
          ]
        end
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "message" => "Height exceeds the limit of 5 m",
              "limit" => "5 m",
              "attribute" => "height",
              "code" => 4002
            },
            {
              "id" => cargo_item_id,
              "limit" => "Chargeable Weight Exceeded",
              "message" => "Chargeable Weight exceeds the limit of 10000 kg",
              "attribute" => "chargeable_weight",
              "code" => 4005
            }
          ]
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when door to door complete request (invalid aggregate cargo)" do
        let(:items) do
          [
            {
              id: cargo_item_id,
              weight: 12_000,
              width: nil,
              length: nil,
              height: nil,
              volume: 1.0,
              quantity: 1,
              dangerous_goods: false,
              cargoClass: "aggregated_lcl",
              colliType: nil,
              stackable: true
            }
          ]
        end
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "limit" => "Chargeable Weight Exceeded",
              "attribute" => "weight",
              "message" => "Aggregate Chargeable Weight exceeds the limit of 10000 kg",
              "code" => 4006
            },
            {
              "id" => cargo_item_id,
              "limit" => "Chargeable Weight Exceeded",
              "attribute" => "volume",
              "message" => "Aggregate Chargeable Weight exceeds the limit of 10000 kg",
              "code" => 4006
            }
          ]
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when door to door complete request (invalid cargo  & multiple mots)" do
        let(:items) do
          [
            {
              id: cargo_item_id,
              weight: 120,
              width: 120,
              length: 1180,
              height: 120,
              quantity: 1,
              dangerous_goods: false,
              cargoClass: "lcl",
              colliType: "pallet",
              stackable: true
            }
          ]
        end
        let(:expected_errors) do
          [
            {
              "id" => cargo_item_id,
              "limit" => "5 m",
              "message" => "Length exceeds the limit of 5 m",
              "attribute" => "length",
              "code" => 4004
            },
            {
              "attribute" => "chargeable_weight",
              "code" => 4005,
              "id" => cargo_item_id,
              "limit" => "Chargeable Weight Exceeded",
              "message" => "Chargeable Weight exceeds the limit of 10000 kg"
            }
          ]
        end
        let(:air_itinerary) do
          FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: "air", organization: organization)
        end

        before do
          FactoryBot.create(:trucking_hub_availability, hub: air_itinerary.origin_hub, type_availability: trucking_availbilities.first.type_availability)
          FactoryBot.create(:trucking_hub_availability, hub: air_itinerary.destination_hub, type_availability: trucking_availbilities.last.type_availability)
          FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: air_itinerary.origin_hub, location: pickup_trucking_location)
          FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: air_itinerary.destination_hub, carriage: "on", location: delivery_trucking_location)
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
        end

        it_behaves_like "Expected errors are returned"
      end

      context "when no pricing available & invalid cargo" do
        let(:items) do
          [
            {
              id: cargo_item_id,
              weight: 12_000,
              width: nil,
              length: nil,
              height: nil,
              volume: 1.0,
              quantity: 1,
              dangerous_goods: false,
              cargoClass: "lcl",
              colliType: "pallet",
              stackable: true
            }
          ]
        end
        let(:pricings) do
          [FactoryBot.create(:pricings_pricing, load_type: "cargo_item", cargo_class: "lcl", organization: organization)]
        end

        context "when type is 'cargo_item', only the cargo_item errors are returned" do
          let(:types) { ["cargo_item"] }
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

          it_behaves_like "Expected errors are returned"
        end

        context "when the type is 'routing', only the routing errors are returned" do
          let(:types) { ["routing"] }
          let(:expected_errors) do
            [
              {
                "id" => "routing",
                "message" => "No Pricings are available for your route",
                "limit" => nil,
                "attribute" => "routing",
                "code" => 4008
              }
            ]
          end

          it_behaves_like "Expected errors are returned"
        end

        context "when the type is set to both 'routing' and 'cargo_item', only the routing errors are returned" do
          let(:types) { %w[routing cargo_item] }
          let(:expected_errors) do
            [
              {
                "id" => cargo_item_id,
                "message" => "Weight exceeds the limit of 10000 kg",
                "limit" => "10000 kg",
                "attribute" => "weight",
                "code" => 4001
              },
              {
                "id" => "routing",
                "message" => "No Pricings are available for your route",
                "limit" => nil,
                "attribute" => "routing",
                "code" => 4008
              }
            ]
          end

          it_behaves_like "Expected errors are returned"
        end

        context "when types is invalid" do
          let(:types) { ["invalid"] }

          it "returns the error indication the types are invalid" do
            expect(response.body).to eq("{\"types\":[\"must be one of cargo_item | routing\"]}")
          end
        end
      end
    end
  end
end
