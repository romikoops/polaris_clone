# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Schedules" do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
  let(:tenant_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:tender) {
    FactoryBot.create(:quotations_tender, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: "cargo_item")
  }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    [1, 3, 5, 10].map do |num|
      base_date = num.days.from_now
      FactoryBot.create(:legacy_trip,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle,
        closing_date: base_date - 4.days,
        start_date: base_date,
        end_date: base_date + 30.days)
    end
    FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
  end

  path "/v1/quotations/{quotation_id}/schedules/{id}" do
    get "Fetch available schedules" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :quotation_id, in: :path, type: :string, schema: {type: :string}
      parameter name: :id, in: :path, type: :string, schema: {type: :string}

      let(:quotation_id) { tender.quotation_id }
      let(:id) { tender.id }

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
                           carrier: {type: :string},
                           closing: {type: :string},
                           end: {type: :string},
                           service: {type: :string},
                           start: {type: :string},
                           tenderId: {type: :string},
                           vessel: {type: :string, nullable: true},
                           voyageCode: {type: :string, nullable: true}
                         },
                         required: %w[carrier closing end service start tenderId vessel voyageCode]
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

  path "/v1/itineraries/{id}/schedules/enabled" do
    get "Fetch status of schedules" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, schema: {type: :string}
      parameter name: :tenant_id, in: :query, type: :string, schema: {type: :string}

      let(:id) { itinerary.id }
      let(:tenant_id) { tenants_tenant.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     enabled: {type: :boolean}
                   },
                   required: ["enabled"]
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end

#   get "/v1/itineraries/:id/schedules/enabled" do
#     let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant) }
#     let(:request) { {id: itinerary.id} }
#
#     context "when tenant runs a quote shop" do
#       before do
#         FactoryBot.create(:tenants_scope, target: tenants_tenant, content: {closed_quotation_tool: true})
#       end
#
#       example "getting schedules enabled for a tenant" do
#         do_request(request)
#         aggregate_failures do
#           expect(response_data["enabled"]).to eq(false)
#         end
#       end
#     end
#
#     context "when tenant runs a booking shop" do
#       example "getting enableds status for tenant schedules" do
#         do_request(request)
#         aggregate_failures do
#           expect(response_data["enabled"]).to eq(true)
#         end
#       end
#     end
#   end
# end
