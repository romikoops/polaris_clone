# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'CargoItemTypes', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: '1234') }
  let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
  let(:user) do
    FactoryBot.create(
      :tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant
    )
  end
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    cargo_item_type = FactoryBot.create(:legacy_cargo_item_type)
    FactoryBot.create(:legacy_tenant_cargo_item_type, tenant: legacy_tenant, cargo_item_type: cargo_item_type)
  end

  get '/v1/cargo_item_types' do
    example 'Renders a json with all cargo item types' do
      do_request(request)

      expect(response_data.count).to eq 1
    end
  end
end
