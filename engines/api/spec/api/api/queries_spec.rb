# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Queries", type: :request, swagger: true do
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
      result_sets: [FactoryBot.build(:journey_result_set, result_count: 1)])
    FactoryBot.create(:journey_query,
      origin: "bbbbb",
      destination: "bbbbb",
      organization: organization,
      cargo_ready_date: 2.days.from_now,
      created_at: 5.hours.ago,
      client: user,
      result_sets: [FactoryBot.build(:journey_result_set, result_count: 1)])
    organization.scope.update(content: { base_pricing: true })
    allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
    allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
      destination_hub.nexus
    )
  end

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
          items: {
            type: :array,
            items: {
              oneOf: [
                { "$ref" => "#/components/schemas/item_lcl" },
                { "$ref" => "#/components/schemas/item_aggregated_lcl" },
                { "$ref" => "#/components/schemas/item_fcl" }
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
          items: [item]
        }
      end

      response "201", "successful operation (FCL)" do
        let(:cargo_classes) { ["fcl_20"] }
        let(:load_type) { "container" }
        let(:item) do
          {
            stackable: true,
            cargoClass: "fcl_20",
            colliType: "container",
            quantity: 1,
            length: nil,
            width: nil,
            height: nil,
            weight: 1200,
            volume: nil,
            commodities: [{ imo_class: "0", description: "Unknown IMO Class", hs_code: "" }]

          }
        end

        run_test!
      end

      response "201", "successful operation (Aggregated Cargo Items)" do
        let(:item) do
          {
            stackable: true,
            cargoClass: "aggregated_lcl",
            colliType: "pallet",
            quantity: 1,
            length: nil,
            width: nil,
            height: nil,
            volume: 1.44,
            weight: 1200,
            commodities: [{ imo_class: "0", description: "Unknown IMO Class", hs_code: "" }]

          }
        end

        run_test!
      end

      response "201", "successful operation (Cargo Item)" do
        let(:item) do
          {
            stackable: true,
            cargoClass: "lcl",
            colliType: "pallet",
            quantity: 1,
            length: 120,
            width: 100,
            height: 120,
            volume: nil,
            weight: 1200,
            commodities: [{ imo_class: nil, description: "No Dangerous Goods", hs_code: "" }]
          }
        end

        run_test!
      end
    end

    get "Fetch all queries" do
      tags "Query"
      description "Fetch all queries"
      operationId "getQueries"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :sort_by,
                in: :query,
                type: :string,
                description: "The attribute by which to sort the Queries"
      parameter name: :direction,
                in: :query,
                type: :string,
                description: "The defining whether the sorting is ascending or descending"
      parameter name: :page,
                in: :query,
                type: :string,
                description: "The page of result requested"
      parameter name: :per_page,
                in: :query,
                type: :string,
                description: "The number of results requested per page"

      response "200", "successful operation" do
        let(:sort_by) { "created_at" }
        let(:direction) { "desc" }
        let(:page) { "1" }
        let(:per_page) { "10" }

        run_test!
      end
    end
  end
end
