# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "ColliTypes", type: :request, swagger: true do
  let(:organization_id) { FactoryBot.create(:organizations_organization).id }
  let(:client) { FactoryBot.create(:users_client, organization_id: organization_id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: client.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:legacy_cargo_item_type_pallet) { FactoryBot.create(:legacy_cargo_item_type, category: "Pallet") }

  path "/v2/organizations/{organization_id}/colli_types" do
    get "Fetch colli types for the Organization" do
      tags "ColliTypes"
      description "Fetch colli types for the Organization"
      operationId "getColliType"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
