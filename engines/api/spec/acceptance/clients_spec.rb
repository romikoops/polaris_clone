# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Clients', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: 'imc-demo') }
  let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:shipper) { FactoryBot.create(:legacy_user, email: 'test-user@example.com', tenant: legacy_tenant, role: role) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    legacy_user = legacy_tenant.users.create(guest: false)
    tenants_user = FactoryBot.create(:tenants_user, tenant: tenant, legacy_id: legacy_user.id)
    FactoryBot.create(:profiles_profile, user_id: tenants_user.id)
  end

  get '/v1/clients' do
    parameter :q, '[Optional] Search term to be queried for'
    response_field :id, 'Unique identifier', Type: String
    response_field :tenant_id, "User's tenant id", Type: Integer
    %w[last-name first-name email company-name phone].each do |field|
      response_field field, "Registered User's #{field}", Type: :String
    end

    example_request 'Returns list of clients' do
      explanation <<-DOC
        Use this endpoint to return a list of clients for a specific tenant
      DOC
      expect(status).to eq 200
    end

    context 'when performing a search request' do
      before do
        FactoryBot.create(:profiles_profile, user_id: Tenants::User.find_by(legacy_id: shipper.id).id)
      end

      example do
        do_request(q: 'test')
        expect(response_data.first['attributes']['email']).to eq(shipper.email)
      end
    end
  end

  get 'v1/clients/:id' do
    parameter :id, 'The client to be retrieved'
    let(:id) { legacy_tenant.users.take.id }
    response_field :id, 'Unique identifier', Type: :UUID
    response_field :tenant_id, "User's tenant id", Type: Integer
    %w[last-name first-name email company-name phone].each do |field|
      response_field field, "Registered User's #{field}", Type: :String
    end

    example_request 'Retrieving client information' do
      explanation <<-DOC
        Takes in the client_id and returns the corresponding client
      DOC
      expect(status).to eq(200)
    end
  end

  post '/v1/clients' do
    let(:user_info) { FactoryBot.attributes_for(:legacy_user).merge(group_id: tenant_group.id) }
    let(:profile_info) { FactoryBot.attributes_for(:profiles_profile) }
    let(:country) { FactoryBot.create(:legacy_country) }
    let(:role) { FactoryBot.create(:legacy_role) }
    let(:perform_request) { subject }
    let(:address_info) do
      { street: 'Brooktorkai', house_number: '7', city: 'Hamburg', postal_code: '22047', country: country.name }
    end

    with_options scope: :client, with_example: true do
      parameter :email
      parameter :first_name
      parameter :last_name
      parameter :role, 'Role name for client (one of shipper, agency_manager, agent)'
      parameter :company_name
      parameter :phone
      parameter :house_number
      parameter :street, "Street name from client's address"
      parameter :postal_code
      parameter :country, 'Country where client is located (part of address)'
      parameter :group_id, 'Tenants group_id for client to be assigned to'
    end

    response_field :id, 'Unique identifier', Type: :UUID
    %w[last-name first-name email company-name phone].each do |field|
      response_field field, "Registered User's #{field}", Type: :String
    end

    context 'when successful' do
      example 'Creating a client for tenant' do
        do_request(client: { **user_info, **profile_info, **address_info, role: role.name })
        response_data = JSON.parse(response_body)
        expect(response_data['data']['attributes']['email']).to eq(user_info[:email])
      end
    end

    context 'with bad request' do
      example 'Creating a client with missing required attributes' do
        do_request(client: { role: role.name })
        expected_response = {
          'error' => "Validation failed: Email can't be blank, Email is invalid"
        }
        expect(JSON.parse(response_body)).to eq(expected_response)
      end
    end
  end

  patch 'v1/clients/:id/password_reset' do
    parameter :id, 'The ID of client requiring a new password'
    let(:id) { user.id }
    response_field :password, 'The newly generated password', Type: String

    example_request 'Generating a new password for a client' do
      expect(status).to eq(200)
      expect(response_data.dig('password')).not_to be_nil
    end
  end
end
