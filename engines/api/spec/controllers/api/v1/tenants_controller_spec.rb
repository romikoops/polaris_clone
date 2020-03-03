# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::TenantsController, type: :controller do
    routes { Engine.routes }
    subject(:tenant_request) do
      request.headers['Authorization'] = token_header
      request_object
    end

    let!(:tenant) { FactoryBot.create(:tenants_tenant) }
    let!(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe 'GET #index' do
      let(:request_object) do
        get :index, as: :json
      end

      it 'renders the list of tenants successfully' do
        JSON.parse(tenant_request.body)
        expect(response_data[0]['attributes']['slug']).to eq(tenant.slug)
      end
    end
  end
end
