# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Itineraries', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant)
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

  get '/v1/itineraries/ports/:tenant_uuid' do
    parameter :tenant_uuid, 'The Tenant UUID'
    parameter :location_type, 'Location Id Type of request origin/destination'
    parameter :location_id, 'Id of selected location'
    parameter :query, 'Text input for query'

    let(:tenant_uuid) { tenant.id }
    let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:location_type) { 'origin' }
    let(:location_id) { nil }
    let(:query) { itinerary.stops.first.hub[:name] }

    response_field response_field :data, 'Matched results', Type: :array, items: {
      'type': :object,
      'title': :data,
      'properties': {
        id: {
          type: Integer,
          description: 'Hub Id'
        },
        type: {
          type: String,
          description: 'Return type'
        },
        attributes: {
          type: :object,
          properties: {
            type: String,
            description: 'Hub / Location name'
          }
        }
      }
    }

    example_request 'Returns list of ports belonging to a tenant' do
      explanation <<-DOC
        Use this endpoint to return a list of ports for a specific tenant
      DOC
      expect(status).to eq 200
    end
  end
end
