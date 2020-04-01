# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Locations', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:address) { FactoryBot.build(:gothenburg_address) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:load_type) { 'cargo_item' }

  get '/v1/locations/origins' do
    parameter :q, 'a text to search for through all available origins'

    context 'when a destination is chosen' do
      parameter :id, 'the id of the origin'

      example 'Renders a json of origins avaialable for the chosen destination' do
        request = { id: destination_hub.nexus_id, load_type: load_type }

        do_request(request)

        expect(response_data.count).to eq 1
      end
    end

    context 'when a destination address is chosen' do
      before do
        itinerary
        Geocoder::Lookup::Test.add_stub([57.694253, 11.854048], [
                                          'address_components' => [{ 'types' => ['premise'] }],
                                          'address' => 'Göteborg, Sweden',
                                          'city' => 'Gothenburg',
                                          'country' => 'Sweden',
                                          'country_code' => 'SE',
                                          'postal_code' => '43813'
                                        ])
      end

      parameter :lat, 'the Latitude of the chosen address'
      parameter :lng, 'the Longitude of the chosen address'

      example 'Renders a json of origins available for the chosen destination address' do
        request = { lat: address.latitude, lng: address.longitude, load_type: load_type }

        do_request(request)

        aggregate_failures do
          expect(response_data.count).to eq 0
          expect(status).to eq 200
        end
      end
    end

    context 'when no destination is chosen' do
      before do
        itinerary
      end

      example 'Renders a json of origins' do
        request = { q: 'goth', load_type: load_type }

        do_request(request)

        aggregate_failures do
          expect(response_data.count).to eq 1
          expect(status).to eq 200
        end
      end
    end
  end

  get '/v1/locations/destinations' do
    parameter :q, 'a text to search for through all available destinations'

    context 'when an origin is chosen' do
      parameter :id, 'the id of the origin'

      example 'Renders a json of destinations avaialable for the chosen origin' do
        request = { id: origin_hub.nexus_id, load_type: load_type }

        do_request(request)
        aggregate_failures do
          expect(response_data.count).to eq 1
          expect(status).to eq 200
        end
      end
    end

    context 'when an origin address is chosen' do
      before do
        itinerary
        Geocoder::Lookup::Test.add_stub([57.694253, 11.854048], [
                                          'address_components' => [{ 'types' => ['premise'] }],
                                          'address' => 'Göteborg, Sweden',
                                          'city' => 'Gothenburg',
                                          'country' => 'Sweden',
                                          'country_code' => 'SE',
                                          'postal_code' => '43813'
                                        ])
        location = FactoryBot.create(:trucking_location, :zipcode, zipcode: '43813')
        FactoryBot.create(:trucking_trucking, carriage: 'pre', hub: origin_hub, tenant: legacy_tenant, location: location)
        FactoryBot.create(:tenants_scope, target: tenant, content: { base_pricing: true })
      end

      parameter :lat, 'the Latitude of the chosen address'
      parameter :lng, 'the Longitude of the chosen address'

      example 'Renders a json of destinations available for the chosen origin' do
        request = { lat: address.latitude, lng: address.longitude, load_type: load_type }

        do_request(request)

        aggregate_failures do
          expect(response_data.count).to eq 1
          expect(status).to eq 200
        end
      end
    end

    context 'when no origin is chosen' do
      before do
        itinerary
      end

      example 'Renders a json of destinations' do
        request = { q: 'shang', load_type: load_type }

        do_request(request)

        aggregate_failures do
          expect(response_data.count).to eq 1
          expect(status).to eq 200
        end
      end
    end
  end
end
