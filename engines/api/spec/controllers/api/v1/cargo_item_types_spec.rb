# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::CargoItemTypesController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers['Authorization'] = token_header
      FactoryBot.create(:legacy_tenant_cargo_item_type, tenant: legacy_tenant, cargo_item_type: cargo_item_type)
    end

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: '1234') }
    let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }

    describe 'GET #index' do
      it 'renders the list of cargo_item_types successfully' do
        get :index

        aggregate_failures do
          expect(response).to be_successful
          expect(response_data.length).to eq(1)
        end
      end
    end
  end
end
