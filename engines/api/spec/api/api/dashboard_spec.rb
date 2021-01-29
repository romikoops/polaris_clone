# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Dashboard", type: :request, swagger_doc: "v1/swagger.json" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

  let(:start_date) { Time.zone.local(2020, 2, 10) }
  let(:shipment_date) { Time.zone.local(2020, 2, 20) }
  let(:end_date) { Time.zone.local(2020, 3, 10) }

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/dashboard" do
    get "Fetch Dashboard Widget" do
      tags "Dashboard"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :widget, in: :query, type: :string, schema: {type: :string}
      parameter name: :start_date, in: :query, type: :string, schema: {type: :string}
      parameter name: :end_date, in: :query, type: :string, schema: {type: :string}

      let(:widget) { "booking_count" }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {type: :number}
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
