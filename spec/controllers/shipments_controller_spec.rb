# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShipmentsController do
  let(:shipment) { create(:shipment) }
  let(:user) { create(:user, tenant: shipment.tenant) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns an http status of success' do
      get :index, params: { tenant_id: shipment.tenant }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'Patch #update_user' do
    before do
      patch :update_user, params: { tenant_id: shipment.tenant_id, id: shipment.id }
      shipment.reload
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'updates the shipment user' do
      expect(shipment.user_id).to eq(user.id)
    end
  end
end
