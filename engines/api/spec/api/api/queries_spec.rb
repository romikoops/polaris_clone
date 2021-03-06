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
  let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }

  let(:user_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:company_id) { FactoryBot.create(:companies_company, organization_id: organization_id, name: "default").id }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:journey_query,
      origin: "aaaaa",
      destination: "aaaaa",
      organization: organization,
      cargo_ready_date: 3.days.from_now,
      created_at: 2.hours.ago,
      client: user_client,
      results: [FactoryBot.build(:journey_result)])
    FactoryBot.create(:journey_query,
      origin: "bbbbb",
      destination: "bbbbb",
      organization: organization,
      cargo_ready_date: 2.days.from_now,
      created_at: 5.hours.ago,
      client: user_client,
      results: [FactoryBot.build(:journey_result)])
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
          parentId: {
            type: :string,
            description: "The ID of the original Query that the current Query is based off.",
            nullable: true
          },
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
          cargoReadyDate: {
            type: :string,
            description: "The date the cargo is expected to be ready for collection/drop off. This date will be used to find what rates are valid for the journey.",
            nullable: true
          },
          items: {
            type: :array,
            items: {
              anyOf: [
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
      let(:user) { user_client }

      response "201", "successful operation (FCL)" do
        let(:cargo_classes) { ["fcl_20"] }
        let(:load_type) { "container" }
        let(:item) do
          {
            stackable: true,
            cargoClass: "fcl_20",
            colliType: nil,
            quantity: 1,
            length: nil,
            width: nil,
            height: nil,
            weight: 1200,
            volume: nil,
            commodities: [{ imoClass: "0", description: "Unknown IMO Class", hsCode: "" }]

          }
        end

        run_test!
      end

      response "201", "successful operation (Aggregated Cargo Items)" do
        let(:item) do
          {
            stackable: true,
            cargoClass: "aggregated_lcl",
            colliType: nil,
            quantity: 1,
            length: nil,
            width: nil,
            height: nil,
            volume: 1.44,
            weight: 1200,
            commodities: [{ imoClass: "0", description: "Unknown IMO Class", hsCode: "" }]

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

    get "Fetch all queries" do
      tags "Query"
      description "Fetch all queries"
      operationId "getQueries"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :sortBy,
        in: :query,
        type: :string,
        description: "The attribute by which to sort the Queries",
        enum: %w[
          load_type
          last_name
          origin
          destination
          selected_date
          cargo_ready_date
          created_at
        ]
      parameter name: :direction,
        in: :query,
        type: :string,
        description: "The defining whether the sorting is ascending or descending",
        enum: %w[
          asc
          desc
        ]
      parameter name: :searchBy,
        in: :query,
        type: :string,
        description: "The attribute of the Query model to search through",
        enum: %w[
          client_email
          client_name
          company_name
          destination
          hs_code
          imo_class
          load_type
          origin
          reference
          mot
        ]
      parameter name: :searchQuery,
        in: :query,
        type: :string,
        description: "The value we want to use in our search"
      parameter name: :page,
        in: :query,
        type: :string,
        description: "The page of result requested"
      parameter name: :perPage,
        in: :query,
        type: :string,
        description: "The number of results requested per page"

      response "200", "successful operation" do
        let(:sortBy) { "created_at" }
        let(:direction) { "desc" }
        let(:searchBy) { "client_email" }
        let(:searchQuery) { user.email }
        let(:page) { "1" }
        let(:perPage) { "10" }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/queries/{id}" do
    let(:query) do
      FactoryBot.create(:journey_query,
        organization: organization,
        client: user_client,
        results: [FactoryBot.build(:journey_result)])
    end

    get "Fetch Query" do
      tags "Query"
      description "Fetch Query"
      operationId "getQuery"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "The Query ID"

      response "200", "successful operation" do
        let(:id) { query.id }

        run_test!
      end
    end

    patch "Update Query" do
      tags "Query"
      description "Update Query"
      operationId "updateQuery"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "The Query ID"

      response "200", "successful operation" do
        let(:id) { FactoryBot.create(:journey_query, client_id: nil, creator: nil, organization: organization).id }

        run_test!
      end

      response "401", "Unauthorized as Query has a client already" do
        let(:id) { FactoryBot.create(:journey_query, organization: organization).id }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/queries/{query_id}/recalculate" do
    let(:query) do
      FactoryBot.create(:journey_query,
        organization: organization,
        origin_geo_id: origin.id,
        destination_geo_id: destination.id,
        source_id: source.id,
        client: user_client,
        results: [FactoryBot.build(:journey_result)])
    end

    post "Recalculate Query" do
      tags "Query"
      description "Recalculate Query"
      operationId "recalculateQuery"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :query_id, in: :path, type: :string, description: "The Query ID"

      response "201", "successful operation" do
        let(:query_id) { query.id }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/admin/companies/{company_id}/queries" do
    get "Fetch all queries" do
      tags "Query"
      description "Fetch all queries"
      operationId "getQueries"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The company ID"
      parameter name: :sortBy,
        in: :query,
        type: :string,
        description: "The attribute by which to sort the Queries",
        enum: %w[
          load_type
          last_name
          origin
          destination
          selected_date
          cargo_ready_date
          created_at
        ]
      parameter name: :direction,
        in: :query,
        type: :string,
        description: "The defining whether the sorting is ascending or descending",
        enum: %w[
          asc
          desc
        ]
      parameter name: :searchBy,
        in: :query,
        type: :string,
        description: "The attribute of the Query model to search through",
        enum: %w[
          client_email
          client_name
          destination
          hs_code
          imo_class
          load_type
          origin
          reference
          mot
        ]
      parameter name: :searchQuery,
        in: :query,
        type: :string,
        description: "The value we want to use in our search"
      parameter name: :page,
        in: :query,
        type: :string,
        description: "The page of result requested"
      parameter name: :perPage,
        in: :query,
        type: :string,
        description: "The number of results requested per page"

      response "200", "successful operation" do
        let(:sortBy) { "created_at" }
        let(:direction) { "desc" }
        let(:searchBy) { "client_email" }
        let(:searchQuery) { user.email }
        let(:page) { "1" }
        let(:perPage) { "10" }

        run_test!
      end
    end
  end
end
