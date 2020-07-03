# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Itineraries" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
  let!(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/itineraries" do
    get "Fetch list of itineraries belonging to an organization" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

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
                           modeOfTransport: {type: :string},
                           name: {type: :string}
                         },
                         required: %w[id modeOfTransport name]
                       },
                       relationships: {
                         type: :object,
                         properties: {
                           stops: {
                             type: :object,
                             properties: {
                               data: {
                                 type: :array,
                                 items: {
                                   type: :object,
                                   properties: {
                                     id: {type: :string},
                                     type: {type: :string}
                                   },
                                   required: %w[id type]
                                 }
                               }
                             },
                             required: ["data"]
                           }
                         }
                       }
                     },
                     required: %w[id type attributes relationships]
                   }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
