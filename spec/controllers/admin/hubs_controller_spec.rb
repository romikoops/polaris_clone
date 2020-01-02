# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::HubsController, type: :controller do
  let(:tenant) { create(:tenant) }
  let(:hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:user) { create(:user, tenant_id: tenant.id) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns a response with paginated results' do
      get :index, params: { tenant_id: hub.tenant.id, hub_type: hub.hub_type, hub_status: hub.hub_status }
      expect(response).to have_http_status(:success)
    end
  end
end
