# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Charges" do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
  let(:tenant_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:origin_hub) { itinerary.hubs.find_by(name: "Gothenburg Port") }
  let(:destination_hub) { itinerary.hubs.find_by(name: "Shanghai Port") }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, tenant: tenants_tenant, user: user) }
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:tender) { shipment.charge_breakdowns.first.tender }
  let(:shipment) {
    FactoryBot.create(:legacy_shipment,
      with_full_breakdown: true, with_tenders: true, trip: trip, tenant: tenant, user: user)
  }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenant_user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/quotations/{quotation_id}/charges/{id}" do
    let(:quotation_id) { tender.quotation_id }
    let(:id) { tender.id }

    get "Fetch tender charges" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, description: "Trip ID of the tender"
      parameter name: :quotation_id, in: :path, type: :string, description: "The selected quotation ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: {type: :string},
                     type: {type: :string},
                     attributes: {
                       type: :object,
                       properties: {
                         charges: {
                           type: :array,
                           items: {
                             type: :object,
                             properties: {
                               id: {type: :string},
                               route: {type: :string},
                               vessel: {type: :string},
                               transitTime: {type: :integer},
                               charges: {
                                 type: :array,
                                 items: {"$ref" => "#/components/schemas/charge"}
                               }
                             }
                           }
                         }
                       },
                       required: %w[charges]
                     }
                   },
                   required: %w[id type attributes]
                 }
               },
               required: ["data"]

        run_test!
      end

      response "404", "Invalid Charge ID" do
        let(:id) { "deadbeef" }

        run_test!
      end
    end
  end
end
