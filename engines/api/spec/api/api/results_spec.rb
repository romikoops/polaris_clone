# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Results", type: :request, swagger_doc: "v2/swagger.json" do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:result_set) { FactoryBot.create(:journey_result_set) }

  path "/v2/organizations/{organization_id}/result_sets/{result_set_id}/results" do
    get "Fetch Results for the Result Set" do
      tags "Results"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, schema: {type: :string}, description: "Organization ID"
      parameter name: :result_set_id, in: :path, type: :string, schema: {type: :string}, description: "ResultSet ID"

      let(:organization_id) { organization.id }
      let(:result_set_id) { result_set.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/restfulResponse"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
