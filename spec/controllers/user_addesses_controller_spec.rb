# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAddressesController do
  describe 'GET #index' do
    let(:user) { create(:user) }
    let(:addresses) { create_list(:address, 5) }

    before do
      user.addresses = addresses
    end

    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :index, params: { tenant_id: user.tenant.id, user_id: user.id }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json['success']).to eq true
      expect(json.dig('data').count).to eq addresses.count
    end
  end
end
