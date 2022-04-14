# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Validation", type: :request, swagger: true do
  include_context "complete_route_with_trucking"
  let(:load_type) { "cargo_item" }
  let(:params) do
    {
      items: items,
      loadType: loadType,
      originId: originId,
      destinationId: destinationId
    }
  end
  let(:access_token) do
    FactoryBot.create(:access_token,
      resource_owner_id: user.id,
      scopes: "public",
      application: source)
  end
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:cargo_classes) { ["lcl"] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:source) { FactoryBot.create(:application, name: "siren") }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:journey_query,
      origin: "aaaaa",
      destination: "aaaaa",
      organization: organization,
      cargo_ready_date: 3.days.from_now,
      created_at: 2.hours.ago,
      client: user,
      results: [FactoryBot.build(:journey_result)])
    FactoryBot.create(:journey_query,
      origin: "bbbbb",
      destination: "bbbbb",
      organization: organization,
      cargo_ready_date: 2.days.from_now,
      created_at: 5.hours.ago,
      client: user,
      results: [FactoryBot.build(:journey_result)])
    FactoryBot.create(:legacy_max_dimensions_bundle, width: 10, height: 10, payload_in_kg: 10, organization: organization, itinerary: itinerary)
    allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
    allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
      destination_hub.nexus
    )
  end

  path "/v2/organizations/{organization_id}/validation" do
    post "Create new Validation" do
      tags "Validations"
      description "Validate Query inputs and receive error and warnings if items exceed preset limits"
      operationId "createValidations"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :query, in: :body, schema: {
        type: :object,
        properties: {
          originId: {
            type: :string,
            description: "The Carta ID of the origin point"
          },
          destinationId: {
            type: :string,
            description: "The Carta ID of the destination point"
          },
          loadType: {
            type: :string,
            description: "The load type of the query"
          },
          types: {
            type: :array,
            items: {
              type: :string,
              description: "The type of the query",
              enum: %w[cargo_item routing]
            }
          },
          items: {
            type: :array,
            items: {
              anyOf: [
                { "$ref" => "#/components/schemas/validation_item_lcl" },
                { "$ref" => "#/components/schemas/validation_item_aggregated_lcl" },
                { "$ref" => "#/components/schemas/validation_item_fcl" }
              ]
            }
          }
        }, required: %w[originId destinationId loadType items]
      }

      let(:query) do
        {
          originId: origin.id,
          destinationId: destination.id,
          loadType: load_type,
          types: ["cargo_item"],
          items: [item]
        }
      end

      response "200", "successful operation (Cargo Item)" do
        let(:item) do
          {
            id: SecureRandom.uuid,
            stackable: true,
            cargoClass: "lcl",
            colliType: "pallet",
            quantity: 1,
            length: 120,
            width: 100,
            height: 120,
            volume: nil,
            weight: 1200,
            commodities: [{ imoClass: nil, description: "No Dangerous Goods", hsCode: "" }]
          }
        end

        run_test!
      end

      response "422", "invalid request (missing items)" do
        let(:query) do
          {
            originId: origin.id,
            destinationId: destination.id,
            loadType: load_type,
            items: []
          }
        end

        run_test!
      end
    end
  end
end
