# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CurrenciesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:tenants_scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)

    Tenants::Scope.create!(target: tenants_user, content: { fixed_exchange_rate: true })
    %w[EUR USD BIF AED].each do |currency|
      stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=#{currency}")
        .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34, USD: 1.3 } }.to_json, headers: {})
    end
  end

  describe 'POST #set_rates' do
    let(:new_rates) { { 'EUR' => '1.2', 'USD' => '0.67' } }

    it 'returns an http status of success' do
      post :set_rates, params: { tenant_id: tenant.id, rates: new_rates, base: 'EUR' }
      expect(response).to have_http_status(:success)
    end

    it 'updates the currency rates of the tenant' do
      post :set_rates, params: { tenant_id: tenant.id, rates: new_rates, base: 'EUR' }
      target = Currency.find_by(tenant_id: tenant.id)
      expect(target.today).to eq(new_rates)
    end
  end

  describe 'POST #toggle_mode' do
    it 'returns an http status of success' do
      post :toggle_mode, params: { tenant_id: tenant.id }
      expect(response).to have_http_status(:success)
    end

    it 'toggles the fixed exchange rate attribute of a tenants scope' do
      post :toggle_mode, params: { tenant_id: tenant.id }
      updated_scope = Tenants::ScopeService.new(target: tenants_user, tenant: tenants_tenant).fetch
      expect(updated_scope['fixed_exchange_rate']).to eq(true)
    end
  end
end
