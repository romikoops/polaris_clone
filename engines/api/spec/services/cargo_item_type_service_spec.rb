# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe CargoItemTypeService, type: :service do
    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: '1234') }
    let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }

    before do
      FactoryBot.create(:legacy_tenant_cargo_item_type, tenant: legacy_tenant, cargo_item_type: cargo_item_type)
    end

    describe '.perform' do
      it 'returns all the cargo item types' do
        results = described_class.new(tenant: tenant).perform

        expect(results.first.id).to eq(cargo_item_type.id)
      end
    end
  end
end
