# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::CargoItemTypesController, type: :controller do
    routes { Engine.routes }
    subject do
      request.headers['Authorization'] = token_header
      request_object
    end

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    before do
      allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
    end

    context 'with cargo item types present' do
      let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }
      let(:request_object) { get :index, as: :json }

      before { Legacy::TenantCargoItemType.create(tenant: legacy_tenant, cargo_item_type_id: cargo_item_type.id) }

      it 'is successful' do
        expect(response).to be_successful
      end

      it 'returns the cargo items belonging to the tenant' do
        data = JSON.parse(subject.body)
        expect(data.first['id']).to eq(cargo_item_type.id)
      end
    end
  end
end
