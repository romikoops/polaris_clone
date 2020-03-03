# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Tenants' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:tenant) { FactoryBot.create(:tenants_tenant) }
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
end
