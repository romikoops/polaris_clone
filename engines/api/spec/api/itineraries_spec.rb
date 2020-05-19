# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Itineraries" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let!(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant) }

  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/itineraries" do
    get "Fetch list of itineraries belonging to a tenant" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

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

  path "/v1/itineraries/ports/{tenant_id}" do
    get "Fetch list of ports" do
      tags "Ahoy"
      consumes "application/json"
      produces "application/json"

      parameter name: :tenant_id, in: :path, type: :string, schema: {type: :string}
      parameter name: :location_type, in: :query, type: :string, schema: {type: :string},
                description: "Location Type of request origin/destination"
      parameter name: :location_id, in: :query, type: :string, schema: {type: :string},
                description: "ID of selected location"
      parameter name: :query, in: :query, type: :string, schema: {type: :string},
                description: "Text input for query"

      let(:tenant_id) { tenant.id }
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
