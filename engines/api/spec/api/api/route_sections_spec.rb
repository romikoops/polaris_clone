# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "RouteSections", type: :request, swagger: true do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let!(:result) { FactoryBot.create(:journey_result, sections: 0) }
  let!(:route_section) { FactoryBot.create(:journey_route_section, result: result, carrier: routing_carrier.name) }
  let(:routing_carrier) { FactoryBot.create(:routing_carrier) }

  path "/v2/organizations/{organization_id}/results/{result_id}/route_sections" do
    get "Fetch RouteSection for the Result" do
      tags "Query"
      description "Fetch RouteSection for the Result"
      operationId "getRouteSections"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"
      parameter name: :result_id, in: :path, type: :string, description: "Result ID of the RouteSections"

      let(:organization_id) { organization.id }
      let(:result_id) { route_section.result_id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       attributes: { "$ref" => "#/components/schemas/routeSection" }
                     },
                     required: ["attributes"]
                   }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
