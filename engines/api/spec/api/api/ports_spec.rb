# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Ports", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user) }
  let!(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before { FactoryBot.create(:users_membership, organization: organization, user: user) }

  path "/v1/organizations/{organization_id}/ports" do
    get "Fetch list of ports" do
      tags "Ahoy"
      description "Fetch list of ports"
      operationId "getPorts"

      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"
      parameter name: :location_type, in: :query, type: :string,
                description: "Location Type of request origin/destination"
      parameter name: :location_id, in: :query, type: :string,
                description: "ID of selected location"
      parameter name: :query, in: :query, type: :string,
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
