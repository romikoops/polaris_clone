# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController do
  let(:addresses) { create_list(:address, 5) }
  let(:user) { create(:user, guest: true, with_profile: true) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    user.addresses = addresses
  end

  describe 'GET #home' do
    let(:user) { create(:user, with_profile: true) }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns an http status of success' do
      get :home, params: { tenant_id: user.tenant, user_id: user.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user, with_profile: true) }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns an http status of success' do
      get :show, params: { tenant_id: user.tenant, user_id: user.id }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body.dig('data', 'id')).to eq(user.id)
        expect(body.dig('data', 'inactivityLimit')).to eq(86_400)
      end
    end
  end

  describe 'POST #update' do
    it 'returns http success, updates the user and send the email' do
      allow(user).to receive(:send_confirmation_instructions).and_return(true)
      params = {
        tenant_id: user.tenant_id,
        user_id: user.id,
        update: {
          company_name: 'Person Freight',
          company_number: 'Person Freight',
          confirm_password: 'testtest',
          email: 'wkbeamish+123@gmail.com',
          first_name: 'Test',
          guest: false,
          last_name: 'Person',
          password: 'testtest',
          phone: '01628710344',
          tenant_id: user.tenant_id
        }
      }
      post :update, params: params
      expect(response).to have_http_status(:success)
      expect(user.guest).to eq false
      expect(user).to have_received(:send_confirmation_instructions).once
    end

    context 'when updating with no profile attributes' do
      let(:params) do
        {
          tenant_id: user.tenant_id,
          user_id: user.id,
          update: {
            guest: true
          }
        }
      end

      it 'returns http status and updates the user' do
        post :update, params: params
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST currencies' do
    let(:rates) { { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34, USD: 1.3 } } }

    before do
      stub_request(:get, 'http://data.fixer.io/latest?access_key=FAKEKEY&base=EUR')
        .to_return(status: 200, body: rates.to_json, headers: {})

      stub_request(:get, 'http://data.fixer.io/latest?access_key=FAKEKEY&base=BRL')
        .to_return(status: 200, body: rates.to_json, headers: {})
    end

    it 'returns http success' do
      post :set_currency, params: { tenant_id: user.tenant.id, user_id: user.id, currency: 'EUR' }
      expect(response).to have_http_status(:success)
    end

    it 'changes the user default currency' do
      post :set_currency, params: { tenant_id: user.tenant.id, user_id: user.id, currency: 'BRL' }

      user.reload
      expect(user.currency).to eq('BRL')
    end
  end
end
