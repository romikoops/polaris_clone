# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Tenders" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment: shipment) }
  let(:shipment) {
    FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, organization: organization,
                                        user: user)
  }
  let(:charge_category) { shipment.charge_breakdowns.first.charges.first.children_charge_category }
  let(:tender) { quotation.tenders.first }
  let(:line_item) { tender.line_items.first }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    Legacy::ExchangeRate.create(from: "EUR", to: "USD", rate: 1.5)
    Legacy::ExchangeRate.create(from: "USD", to: "EUR", rate: 1.5)
  end

  path "/v1/organizations/{organization_id}/tenders/{id}" do
    put "Update Tenders" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, schema: {type: :string}
      parameter name: :organization_id, in: :query, type: :string, schema: {type: :string}
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          line_item_id: {type: :string},
          charge_category_id: {type: :string},
          value: {type: :string},
          section: {type: :string}
        }
      }

      let(:id) { tender.id }
      let(:organization_id) { organization.id }
      let(:params) do
        {
          charge_category_id: charge_category.id,
          value: 100,
          section: charge_category.code,
          line_item_id: tender.line_items.first.id
        }
      end

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
                               chargeCategoryId: {type: :integer, nullable: true},
                               description: {type: :string, nullable: true},
                               id: {type: :string},
                               level: {type: :integer},
                               lineItemId: {type: :uuid},
                               order: {type: :integer},
                               originalValue: {"$ref" => "#/components/schemas/money"},
                               section: {type: :string, nullable: true},
                               tenderId: {type: :string},
                               value: {"$ref" => "#/components/schemas/money"}
                             },
                             required: %w[chargeCategoryId description id level lineItemId order originalValue section
                               tenderId value]
                           }
                         },
                         route: {type: :string},
                         vessel: {type: :string, nullable: true},
                         id: {type: :string},
                         transitTime: {type: :integer}
                       },
                       required: %w[]
                     }
                   },
                   required: %w[id type attributes]
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
