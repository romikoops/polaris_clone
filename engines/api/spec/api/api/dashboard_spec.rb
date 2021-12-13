# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Dashboard", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user) }

  let(:start_date) { Time.zone.local(2020, 2, 10) }
  let(:shipment_date) { Time.zone.local(2020, 2, 20) }
  let(:end_date) { Time.zone.local(2020, 3, 10) }

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before { FactoryBot.create(:users_membership, organization: organization, user: user) }

  path "/v1/organizations/{organization_id}/dashboard" do
    get "Fetch Dashboard Widget" do
      tags "Dashboard"
      description "Fetch widget date for the dashboard."
      operationId "getDashboard"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :widget, in: :query, type: :string, description: "Widget to be fetch"
      parameter name: :start_date, in: :query, type: :string, description: "Start date of dashboard data"
      parameter name: :end_date, in: :query, type: :string, description: "End date of dashboard data"

      let(:widget) { "booking_count" }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   oneOf: [
                     { "$ref" => "#/components/schemas/analyticsCount" },
                     { "$ref" => "#/components/schemas/analyticsTotal" },
                     { "$ref" => "#/components/schemas/analyticsListCount" }
                   ]
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
