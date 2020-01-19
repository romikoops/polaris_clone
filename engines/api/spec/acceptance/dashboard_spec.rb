# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Dashboard' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header
  let(:email) { 'test3@example.com' }
  let(:password) { 'veryspeciallysecurehorseradish' }
  let!(:quote_tenant) { ::Legacy::Tenant.create(name: 'Demo1', subdomain: 'demo1', scope: { open_quotation_tool: true }) }
  let!(:tenant) { FactoryBot.create(:tenants_tenant, legacy_id: quote_tenant.id) }

  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: quote_tenant, email: 't@example.com') }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }


  before(:each) do
    allow_any_instance_of(Api::ApiController).to receive(:current_user).and_return(user)
  end

  get '/v1/dashboard' do
    example_request 'Returns information of current user' do
      explanation <<-DOC
        Use this endpoint to fetch information of currently signed in user.
      DOC

      expect(status).to eq 200
    end
  end
end
