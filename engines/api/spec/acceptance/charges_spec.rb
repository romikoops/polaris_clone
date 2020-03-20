# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Charges', acceptance: true do
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
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, with_full_breakdown: true, with_tenders: true, trip: trip, tenant: tenant, user: user) }
  let(:tender) { shipment.charge_breakdowns.first.tender }

  before { FactoryBot.create(:tenants_theme, tenant: tenants_tenant) }

  get '/v1/quotations/:quotation_id/charges/:id' do
    with_options scope: :quote, with_example: true do
      parameter :id, 'The charge trip id of the selected tender', required: true
      parameter :quotation_id, 'The selected quotation id', required: true
    end

    context 'when getting tender data' do
      let(:request) do
        {
          quotation_id: tender.quotation_id,
          id: tender.id
        }
      end

      example 'getting details on a particular charge breakdown' do
        do_request(request)
        aggregate_failures do
          expect(status).to eq(200)
          expect(response_data.dig('id')).to eq(shipment.charge_breakdowns.first.tender_id.to_s)
          expect(response_data.dig('attributes').keys).to match_array(%w[charges route transitTime vessel id])
        end
      end
    end
  end
end
