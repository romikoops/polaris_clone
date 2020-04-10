# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Schedules', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
  let(:tenant_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenant_user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:tender) { FactoryBot.create(:quotations_tender, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: 'cargo_item') }

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

  get '/v1/quotations/:quotation_id/schedules/:id' do
    with_options scope: :quote, with_example: true do
      parameter :id, 'The trip id of the selected tender', required: true
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
          expect(response_data.dig(0, 'attributes').keys).to match_array(%w[closing start end service carrier vessel voyageCode tenderId])
        end
      end
    end
  end

  get '/v1/itineraries/:id/schedules/enabled' do
    let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant) }
    let(:request) { { id: itinerary.id } }

    context 'when tenant runs a quote shop' do
      before do
        FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { closed_quotation_tool: true })
      end

      example 'getting schedules enabled for a tenant' do
        do_request(request)
        aggregate_failures do
          expect(response_data['enabled']).to eq(false)
        end
      end
    end

    context 'when tenant runs a booking shop' do
      example 'getting enableds status for tenant schedules' do
        do_request(request)
        aggregate_failures do
          expect(response_data['enabled']).to eq(true)
        end
      end
    end
  end
end
