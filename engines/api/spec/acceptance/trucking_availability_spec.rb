# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'TruckingAvailability' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:country) { FactoryBot.create(:legacy_country) }

  before do
    allow_any_instance_of(Legacy::Address).to receive(:country).and_return(country)
    Geocoder::Lookup::Test.add_stub([57.7072326, 11.9670171], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Göteborg, Sweden',
                                      'city' => 'Gothenburg',
                                      'country' => 'Sweden',
                                      'country_code' => 'SE',
                                      'postal_code' => '43813'
                                    ])
\
  end

  describe 'GET #index' do
    get '/v1/trucking_availability' do
      with_options with_example: true do
        parameter :lat
        parameter :lng
        parameter :load_type
        parameter :carriage
        parameter :hub_ids
        parameter :tenant_id
      end

      let(:lat) { '57.7072326' }
      let(:lng) { '11.9670171' }
      let(:load_type) { 'container' }
      let(:carriage) { 'pre' }
      let(:hub_ids) { '3025,3023' }
      let(:tenant_id) { tenant.id }
      example_request 'Returns available trucking options' do
        explanation <<-DOC
          Use this endpoint to fetch available trucking options for a location.
        DOC

        expect(status).to eq 200
      end
    end
  end
end
