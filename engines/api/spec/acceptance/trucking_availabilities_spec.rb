# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'TruckingAvailabilities' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
                      country_code: 'se')
  end
  let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: 'SE') }
  before do
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: origin_trucking_location)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub)
    Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Göteborg, Sweden',
                                      'city' => 'Gothenburg',
                                      'country' => 'Sweden',
                                      'country_code' => 'SE',
                                      'postal_code' => '43813'
                                    ])
  end

  describe 'GET #index' do
    get '/v1/trucking_availabilities' do
      with_options with_example: true do
        parameter :lat
        parameter :lng
        parameter :load_type
        parameter :tenant_id
      end

      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:load_type) { 'cargo_item' }
      let(:tenant_id) { tenant.id }
      let(:target) { 'origin' }
      let(:request) do
        {
          lat: lat,
          lng: lng,
          load_type: load_type,
          tenant_id: tenant_id,
          target: target
        }
      end
      let(:expected_result) do
        {
          'truckingAvailable' => true,
          'truckTypes' => ['default']
        }
      end
      let(:result) { JSON.parse(response_body) }

      it 'returns the availability and truck types' do
        do_request(request)
        aggregate_failures do
          expect(status).to eq 200
          expect(result).to eq(expected_result)
        end
      end
    end
  end
end
