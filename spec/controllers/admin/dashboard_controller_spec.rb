# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }

  describe 'GET #index' do
    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant }

      expect(response).to have_http_status(:success)
    end
  end
end
