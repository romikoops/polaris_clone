# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Charges" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, organization: organization, user: user) }
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:tender) { shipment.charge_breakdowns.first.tender }
  let(:shipment) {
    FactoryBot.create(:legacy_shipment,
      with_full_breakdown: true, with_tenders: true, trip: trip, organization: organization, user: user)
  }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/organizations/{organization_id}/quotations/{quotation_id}/charges/{id}" do
    let(:quotation_id) { tender.quotation_id }
    let(:id) { tender.id }

    get "Fetch tender charges" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
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
