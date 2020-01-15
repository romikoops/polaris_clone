# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Cargo Item Types' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }

  before do
    Legacy::TenantCargoItemType.create(tenant: legacy_tenant, cargo_item_type_id: cargo_item_type.id)
    allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
  end

  get '/v1/cargo_item_types' do
    response_field :id, 'Unique identifier', Type: Integer
    response_field :dimension_x, 'Length', Type: String
    response_field :dimension_y,  'Width of the cargo item', Type: String
    response_field :dimension_z, 'Height of the cargo item', Type: String
    response_field :area, 'Area occupied by the cargo item', Type: String
    response_field :description, 'A description of the cargo item', Type: String
    response_field :category, 'Category of the cargo item', Type: String

    example_request 'Returns list of cargo item types belonging to a tenant' do
      explanation <<-DOC
        Use this endpoint to return a list of cargo items for a specific tenant
      DOC
      expect(status).to eq 200
    end
  end
end
