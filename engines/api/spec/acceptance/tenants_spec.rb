# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Tenants', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  get '/v1/tenants' do
    example_request 'Returns all tenants of current user' do
      explanation <<-DOC
      Use this endpoint to fetch information of all tenants associated with a signed in user.
      DOC
      expect(status).to eq 200
    end
  end

  get '/v1/tenants/:id/countries' do
    response_field :name, 'Country Name', Type: String
    response_field :code, 'Country Code', Type: String
    response_field :flag, 'Country Flag', Type: String

    let(:id) { tenant.id }
    example_request 'Returns all the countries on which the tenant operates' do
      explanation <<-DOC
      Use this endpoint to fetch all countries on which the tenant operates
      DOC
    end
  end
end
