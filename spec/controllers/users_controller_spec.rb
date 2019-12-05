# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController do
  describe 'POST #update' do
    let(:user) { create(:user, guest: true) }
    let(:addresses) { create_list(:address, 5) }

    before do
      user.addresses = addresses
    end

    it 'returns http success, updates the user and send the email' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
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
  end
end
