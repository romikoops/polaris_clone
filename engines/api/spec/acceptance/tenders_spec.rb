# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Tenders' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
  let(:tenant_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenant_user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, tenant: tenants_tenant, user: user) }
  let(:tender) do
    FactoryBot.create(:quotations_tender,
                      quotation: quotation,
                      origin_hub: origin_hub,
                      destination_hub: destination_hub,
                      tenant_vehicle: tenant_vehicle)
  end

  put '/v1/tenders/:id' do
    parameter :id, 'The Tender Id', required: true
    parameter :line_item_id, 'The LineItem Id'
    parameter :charge_category_id, 'The Id of the carge category of the charge to be updated', required: true
    parameter :value, 'the new value of the charge', required: true
    parameter :section, 'the section to which the charge belongs'

    context :success do
      let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, tenant: tenant, user: user) }
      let(:charge_category) { shipment.charge_breakdowns.first.charges.first.children_charge_category }
      let(:request) do
        {
          id: tender.id,
          charge_category_id: charge_category.id,
          value: 100,
          section: charge_category.code
        }
      end

      before { shipment.charge_breakdowns.update(tender_id: tender.id) }

      example 'updates a line item and its tender' do
        explanation <<-DOC
        Use this endpoint to update the amount of the line item and its tender.
        DOC
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
