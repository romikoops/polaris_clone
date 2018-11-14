require 'rails_helper'
require "#{Rails.root}/app/classes/application_error"

describe 'Authentication by token', type: :request do

  let(:user) { create(:user, tenant: tenant) }

  context 'user logged out' do
    it 'responds correctly, requiring authentication' do
      get subdomain_user_home_path(subdomain_id: tenant.subdomain, user_id: user.id)

      expect(response).to have_http_status(:unauthorized)
      expect(json[:success]).to be_falsy
      expect(json[:code]).to eq(1050)
      expect(json[:message]).to eq("You are not signed in.")
    end
  end

  context 'user logged in' do
    sign_in(:user)
    it 'shows user home page' do
      get tenant_user_home_path(id: tenant.id, user_id: user.id)
      expect(controller.current_user).to eq(user)
    end
  end
end
