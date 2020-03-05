# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::TenantsController, type: :controller do
    routes { Engine.routes }
    before do
      request.headers['Authorization'] = token_header
    end

    let!(:tenant) { FactoryBot.create(:tenants_tenant) }
    let!(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:scope) { Tenants::ScopeService.new(tenant: tenant, target: user).fetch }

    describe 'GET #index' do
      it 'renders the list of tenants successfully' do
        get :index, as: :json

        expect(response_data[0]['attributes']['slug']).to eq(tenant.slug)
      end
    end

    describe 'GET #scope' do
      it 'renders the list of tenants successfully' do
        get :scope, params: { id: tenant.id }, as: :json

        expect(response_json).to match(scope)
      end
    end
  end
end
