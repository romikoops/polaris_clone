# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Clients' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    legacy_user = legacy_tenant.users.create(guest: false)
    tenants_user = FactoryBot.create(:tenants_user, tenant: tenant, legacy_id: legacy_user.id)
    FactoryBot.create(:profiles_profile, user_id: tenants_user.id)
    allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
  end

  get '/v1/clients' do
    response_field :id, 'Unique identifier', Type: String
    response_field :tenant_id, "User's tenant id", Type: Integer
    %w(last-name first-name email company-name phone).each do |field|
      response_field field, "Registered User's #{field}", Type: :String
    end

    example_request 'Returns list of clients' do
      explanation <<-DOC
        Use this endpoint to return a list of clients for a specific tenant
      DOC
      expect(status).to eq 200
    end
  end

  get 'v1/clients/:id' do
    parameter :id, 'The client to be retrieved'
    let(:id) { legacy_tenant.users.take.id }
    response_field :id, 'Unique identifier', Type: :UUID
    response_field :tenant_id, "User's tenant id", Type: Integer
    %w(last-name first-name email company-name phone).each do |field|
      response_field field, "Registered User's #{field}", Type: :String
    end

    example_request 'Retrieving client information' do
      explanation <<-DOC
        Takes in the client_id and returns the corresponding client
      DOC
      expect(status).to eq(200)
    end
  end
end
