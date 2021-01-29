# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Organizations", type: :request, swagger_doc: "v1/swagger.json" do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations" do
    get "Fetch all organizations" do
      tags "Users"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/organization"}
                 }
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end

  path "/v1/organizations/{id}/countries" do
    get "Fetch enabled countries for an organization" do
      tags "Users"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, schema: {type: :string}, description: "Organization ID"

      let(:id) { organization.id }
      let!(:countries) { FactoryBot.create_list(:legacy_hub, 5, organization: organization) }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/country"}
                 }
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end
end
