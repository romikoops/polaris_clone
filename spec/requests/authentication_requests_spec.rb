require 'rails_helper'

describe 'Authentication by token', type: :request do

  let(:user) { create(:user, tenant: tenant) }

  context 'user logged in' do

    sign_in(:user)
    it 'shows user home page' do
      get subdomain_user_home_path(subdomain_id: tenant.subdomain, user_id: user.id)
      expect(controller.current_user).to eq(user)
    end
  end

  context 'user logged out' do

    it 'raises an error' do
      user_id = user.id
      expect {
        get subdomain_user_home_path(subdomain_id: tenant.subdomain, user_id: user_id)
      }.to raise_error(StandardError)
    end
  end

end
