# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Itineraries' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    legacy_tenant.users.create(guest: false)
    allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
  end

  get '/v1/itineraries' do
    response_field :id, 'Unique identifier', Type: String
    response_field :tenant_id, "User's tenant id", Type: Integer
    %w(name mode_of_transport).each do |field|
      response_field field, "each itinerary's #{field}", Type: :String
    end

    example_request 'Returns list of itineraries belonging to a tenant' do
      explanation <<-DOC
        Use this endpoint to return a list of itineraries for a specific tenant
      DOC
      expect(status).to eq 200
    end
  end
end
