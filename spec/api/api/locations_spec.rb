# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Locations" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:address) { FactoryBot.build(:gothenburg_address) }
  let(:load_type) { "cargo_item" }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/locations/origins" do
    get "Fetch available origins" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :q, in: :query, type: :string, schema: {type: :string}
      parameter name: :id, in: :query, type: :string, schema: {type: :string}
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}

      let(:id) { destination_hub.nexus_id }
      let(:q) { nil }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/nexus"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/locations/destinations" do
    get "Fetch available destinations" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :q, in: :query, type: :string, schema: {type: :string}
      parameter name: :id, in: :query, type: :string, schema: {type: :string}
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}

      let(:id) { origin_hub.nexus_id }
      let(:q) { nil }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/nexus"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
