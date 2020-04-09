# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Equipments', acceptance: true do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :token_header

  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: legacy_tenant) }
  let(:fcl_40_hq_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: legacy_tenant) }
  let(:gothenburg) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:shanghai) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:hamburg) { fcl_40_hq_itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:fcl_20_pricing, tenant: legacy_tenant, itinerary: itinerary)
    FactoryBot.create(:fcl_40_pricing, tenant: legacy_tenant, itinerary: itinerary)
    FactoryBot.create(:fcl_40_hq_pricing, tenant: legacy_tenant, itinerary: fcl_40_hq_itinerary)
  end

  get '/v1/equipments' do
    context 'when no origin and no destination are chosen' do
      before do
        itinerary
      end

      example 'Renders all available fcl equipments' do
        do_request({})

        aggregate_failures do
          expect(response_data.count).to eq 3
          expect(status).to eq 200
        end
      end
    end

    context 'when a origin is chosen' do
      parameter :origin_nexus_id, 'the id of the origin'

      example 'Renders a json of equipments avaialable for the chosen origin' do
        request = { origin_nexus_id: shanghai.nexus_id }

        do_request(request)

        expect(response_data.count).to eq 3
      end
    end

    context 'when a destination is chosen' do
      parameter :destination_nexus_id, 'the id of the destination'

      example 'Renders a json of equipments avaialable for the chosen origin' do
        request = { destination_nexus_id: gothenburg.nexus_id }

        do_request(request)

        expect(response_data.count).to eq 2
      end
    end

    context 'when a origin and a destination are chosen' do
      parameter :origin_nexus_id, 'the id of the origin'
      parameter :destination_nexus_id, 'the id of the destination'

      example 'Renders a json of equipments avaialable for the chosen origin' do
        request = {
          origin_nexus_id: shanghai.nexus_id,
          destination_nexus_id: hamburg.nexus_id
        }

        do_request(request)

        expect(response_data.count).to eq 1
      end
    end
  end
end
