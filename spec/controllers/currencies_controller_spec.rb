# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrenciesController, type: :controller do
  let(:currency) { 'EUR' }
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

  before do
    Tenants::Scope.create!(target: tenants_user, content: { fixed_exchange_rate: true })
    %w[EUR USD BIF AED].each do |currency|
      stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=#{currency}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'data.fixer.io',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34, USD: 1.3 } }.to_json, headers: {})
    end
  end

  describe 'GET #currencies_for_base' do
    let(:new_rates) { { 'EUR' => '1.2', 'USD' => '0.67' } }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns an http status of success' do
      post :currencies_for_base, params: { tenant_id: tenant.id, currency: currency }
      expect(response).to have_http_status(:success)
    end

    it 'returns the currency rates the tenant' do
      post :currencies_for_base, params: { tenant_id: tenant.id, currency: currency }

      data = JSON.parse(response.body)['data']
      expect(data.length).to eq(5)
    end
  end

  describe 'GET #refresh_for_base' do
    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns an http status of success' do
      post :refresh_for_base, params: { tenant_id: tenant.id, currency: currency }
      expect(response).to have_http_status(:success)
    end

    it 'updates the exchange rates' do
      post :refresh_for_base, params: { tenant_id: tenant.id, currency: currency }

      data = JSON.parse(response.body)['data']
      expect(data.length).to eq(5)
    end
  end
end
