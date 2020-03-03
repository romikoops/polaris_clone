# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'TenantsGroups' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create_list(:tenants_group, 5, tenant: tenant)
  end

  get '/v1/groups' do
    response_field :id, 'Unique identifier for tenant group', Type: String
    response_field :name, 'Group name', Type: String

    example_request 'Returns list of groups belonging to a tenant' do
      explanation <<-DOC
        Use this enddpoint to return a list of groups for a tenant
      DOC
      response_data = JSON.parse(response_body)
      expect(response_data['data'].count).to eq(5)
    end
  end
end
