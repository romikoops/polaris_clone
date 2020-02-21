# frozen_string_literal: true

require 'rails_helper'

module UserDeviseTokenAuth
  RSpec.describe UsersDeviseTokenAuth::SessionsController, type: :controller do
    describe '#create' do
      let(:tenant) { FactoryBot.create(:tenant) }
      let(:user) { FactoryBot.create(:user, tenant_id: tenant.id, password: 'password') }

      before do
        request.env['devise.mapping'] = Devise.mappings[:user]
        FactoryBot.create(:profiles_profile,
                          first_name: 'Guest',
                          last_name: 'User',
                          phone: '123456789',
                          user_id: Tenants::User.find_by(legacy_id: user.id).id)
      end

      it 'creates a session and returns merged profile' do
        post :create, params: { tenant_id: tenant.id, email: user.email, password: 'password' }
        resp = JSON.parse(response.body)
        expect(resp['data']['first_name']).to eq('Guest')
      end
    end
  end
end
