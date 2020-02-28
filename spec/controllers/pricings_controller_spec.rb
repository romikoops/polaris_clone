# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PricingsController, type: :controller do
  let!(:tenant) { FactoryBot.create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:agency) { FactoryBot.create(:legacy_agency) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role, agency: agency) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:itinerary) { FactoryBot.create(:itinerary, tenant_id: tenant.id) }
  let!(:agency_pricing) { FactoryBot.create(:legacy_pricing, tenant: tenant, itinerary_id: itinerary.id, user_id: agency.agency_manager.id) }
  let!(:user_pricing) { FactoryBot.create(:legacy_pricing, :fcl_40, tenant: tenant, itinerary_id: itinerary.id, user_id: user.id) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns an http status of success' do
      post :index, params: { tenant_id: tenant.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the currency rates the tenant' do
      post :index, params: { tenant_id: tenant.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'itineraries', 0, 'id')).to eq(itinerary.id)
    end

    it 'rejects unauthenticated users' do
      tenant = FactoryBot.create(:legacy_tenant)

      post :index, params: { tenant_id: tenant.id }
      expect(response).to have_http_status(:unauthorized)
    end

    context 'with closed_quotation_tool' do
      before do
        create(:tenants_scope, target: tenants_tenant, content: { closed_quotation_tool: true })
      end

      it 'returns the currency rates the tenant' do
        post :index, params: { tenant_id: tenant.id }

        json = JSON.parse(response.body)
        expect(json.dig('data', 'itineraries', 0, 'id')).to eq(itinerary.id)
      end
    end
  end

  describe 'GET #show' do
    it 'returns an http status of success' do
      post :show, params: { id: itinerary.id, tenant_id: tenant.id }

      expect(response).to have_http_status(:success)
    end

    it 'returns the currency rates the tenant' do
      post :show, params: { id: itinerary.id, tenant_id: tenant.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'itinerary_id')).to eq(itinerary.id.to_s)
    end
  end

  describe 'GET #request_dedicated_pricing' do
    before do
      stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png')
        .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: '', headers: {})

      stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png')
        .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: '', headers: {})
    end

    it 'returns an http status of success' do
      post :request_dedicated_pricing, params: { id: itinerary.id, tenant_id: tenant.id, pricing_id: user_pricing.id, user_id: user.id }

      expect(response).to have_http_status(:success)
    end

    it 'returns the currency rates the tenant' do
      post :request_dedicated_pricing, params: { id: itinerary.id, tenant_id: tenant.id, pricing_id: user_pricing.id, user_id: user.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'itinerary_id')).to eq(itinerary.id)
    end
  end
end
