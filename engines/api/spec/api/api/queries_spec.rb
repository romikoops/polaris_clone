# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Queries", type: :request, swagger: true do
  include_context "complete_route_with_trucking"
  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:source) { FactoryBot.create(:application, name: "siren") }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:carta_double) { double("Carta::Api") }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }

  before do
    ::Organizations.current_id = organization.id
    organization.scope.update(content: {base_pricing: true})
    allow(Carta::Api).to receive(:new).and_return(carta_double)
    allow(carta_double).to receive(:lookup).with(id: origin.id).and_return(origin)
    allow(carta_double).to receive(:lookup).with(id: destination.id).and_return(destination)
    allow(carta_double).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
    allow(carta_double).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
      destination_hub.nexus
    )
  end
  let(:params) {
    {
      aggregated: aggregated,
      items: items,
      loadType: loadType,
      originId: originId,
      destinationId: destinationId
    }
  }
  let(:access_token) do
    FactoryBot.create(:access_token,
      resource_owner_id: user.id,
      scopes: "public",
      application: source)
  end
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v2/organizations/{organization_id}/queries" do
    post "Create new query" do
      tags "Query"
      description "Create new query"
      operationId "createQuery"

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
          aggregated: {
            type: :boolean,
            description: "Whether the cargo is aggregated or not"
          },
          items: {
            type: :array,
            items: {"$ref" => "#/components/schemas/item"}
          }
        }, required: ["originId", "destinationId", "loadType", "aggregated", "items"]
      }

      response "200", "successful operation" do
        let(:query) do
          {
            originId: origin.id,
            destinationId: destination.id,
            loadType: load_type,
            aggregated: false,
            items: [
              {
                stackable: true,
                valid: true,
                dangerous: false,
                cargoItemTypeId: pallet.id,
                quantity: 1,
                length: 120,
                width: 100,
                height: 120,
                weight: 1200,
                commodityCodes: []
              }
            ]
          }
        end

        run_test!
      end
    end
  end
end
