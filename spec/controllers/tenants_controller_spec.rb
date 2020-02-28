# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenantsController do
  let!(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:tenants_domain) { create(:tenants_domain, tenant_id: tenants_tenant.id) }
  let(:user) { create(:user, tenant_id: tenant.id) }

  before do
    FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end

    it 'returns an empty list on production mode' do
      allow(Rails.env).to receive('production?').and_return(true)

      get :index

      json = JSON.parse(response.body)
      expect(json.dig('data')).to be_empty
    end

    it 'returns tenants without production mode' do
      allow(Rails.env).to receive('production?').and_return(false)

      get :index

      json = JSON.parse(response.body)
      expect(json.dig('data', 0, 'value', 'id')).to eq(tenant.id)
    end
  end

  describe 'GET #get_tenant' do
    it 'returns http success' do
      get :get_tenant, params: { tenant_id: tenant.id, name: tenant.subdomain }

      expect(response).to have_http_status(:success)
    end

    it 'returns the tenant' do
      get :get_tenant, params: { tenant_id: tenant.id, name: tenant.subdomain }

      json = JSON.parse(response.body)
      expect(json.dig('id')).to eq tenant.id
    end

    it 'returns 400 if the tenant is not found' do
      get :get_tenant, params: { tenant_id: tenant.id, name: 'not found tenant' }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET #fetch_scope' do
    it 'returns http success' do
      get :fetch_scope, params: { tenant_id: tenant.id }

      expect(response).to have_http_status(:success)
    end

    it 'returns the tenant scope' do
      get :fetch_scope, params: { tenant_id: tenant.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'fee_detail')).to eq('key_and_name')
    end

    it 'returns the tenant scope with current_user' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :fetch_scope, params: { tenant_id: tenant.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'fee_detail')).to eq('key_and_name')
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: tenant.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the tenant without user' do
      get :show, params: { id: tenant.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'tenant', 'id')).to eq(tenant.id)
    end

    it 'returns the tenant with user' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :show, params: { id: tenant.id }

      json = JSON.parse(response.body)
      expect(json.dig('data', 'tenant', 'id')).to eq(tenant.id)
    end
  end

  describe 'GET #current' do
    before do
      request.headers[:HTTP_REFERER] = "http://#{tenants_domain.domain}"
      get :current
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the current tenant' do
      json = JSON.parse(response.body)
      expect(json.dig('data', 'tenant_id')).to eq(tenant.id)
    end
  end
end
