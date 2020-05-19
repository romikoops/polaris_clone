# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Dashboard" do
  let!(:quote_tenant) { ::Legacy::Tenant.create(scope: {open_quotation_tool: true}) }
  let!(:tenant) { FactoryBot.create(:tenants_tenant, legacy_id: quote_tenant.id) }

  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: quote_tenant) }
  let(:start_date) { Time.zone.local(2020, 2, 10) }
  let(:shipment_date) { Time.zone.local(2020, 2, 20) }
  let(:end_date) { Time.zone.local(2020, 3, 10) }

  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/dashboard" do
    get "Fetch Dashboard Widget" do
      tags "Dashboard"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

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
