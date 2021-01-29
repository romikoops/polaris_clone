# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Ports", type: :request, swagger_doc: "v1/swagger.json" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let!(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/ports" do
    get "Fetch list of ports" do
      tags "Ahoy"
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, schema: {type: :string}
      parameter name: :location_type, in: :query, type: :string, schema: {type: :string},
                description: "Location Type of request origin/destination"
      parameter name: :location_id, in: :query, type: :string, schema: {type: :string},
                description: "ID of selected location"
      parameter name: :query, in: :query, type: :string, schema: {type: :string},
                description: "Text input for query"

      let(:organization_id) { organization.id }
      let(:location_type) { "origin" }
      let(:location_id) { nil }
      let(:query) { nil }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: {type: :string},
                       type: {type: :string},
                       attributes: {
                         type: :object,
                         properties: {
                           id: {type: :number},
                           name: {type: :string},
                           hubType: {type: :string}
                         },
                         required: %w[id name hubType]
                       }
                     },
                     required: %w[id type attributes]
                   }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
