# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Cargo Items", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user) }
  let(:groups_group) { Groups::Group.create(organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:users_membership, organization: organization, user: user)
    FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization)
  end

  path "/v1/organizations/{organization_id}/cargo_item_types" do
    get "Fetch all available cargo types" do
      tags "Quote"
      description "Fetches all possible cargo types enabled for the customer."
      operationId "getCargoItemTypes"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/cargo_item_type"}
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
