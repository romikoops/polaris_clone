# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "ActiveLocodes", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:client) { FactoryBot.create(:users_client, organization_id: organization_id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: client.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:gothenburg_shanghai_itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, organization: organization) }

  before do
    FactoryBot.create(:pricings_pricing, itinerary: gothenburg_shanghai_itinerary, organization: organization)
  end

  path "/v2/organizations/{organization_id}/active_locodes" do
    get "Fetch Active Locode lookup for the Organization" do
      tags "ActiveLocodes"
      description "Fetch active locode lookup for the Organization"
      operationId "getActiveLocodes"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"

      response "200", "successful operation" do
        run_test!
      end
    end
  end
end
