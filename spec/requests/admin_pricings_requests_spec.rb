# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/request_spec_helpers'
Dir["#{Rails.root}/spec/support/auxiliary_constants/shipments/*.rb"].each do |file_path|
  require file_path
end

describe 'Pricing requests', type: :request do
  let(:role) { create(:role, name: 'admin') }
  let(:user) { create(:user, tenant: tenant, role: role) }

  let(:transport_category) { create(:transport_category) }

  let(:origin_nexus) { create(:nexus) }
  let(:destination_nexus) { create(:nexus) }
  let!(:ocean_itinerary) { create(:itinerary, tenant: tenant, stops: [ocean_origin_stop, ocean_destination_stop], layovers: [ocean_origin_layover, ocean_destination_layover], trips: [ocean_trip], mode_of_transport: 'ocean') }
  let(:ocean_trip) { create(:trip) }
  let(:ocean_origin_hub) { create(:hub, tenant: tenant, nexus: origin_nexus) }
  let(:ocean_destination_hub) { create(:hub, tenant: tenant, nexus: destination_nexus) }
  let(:ocean_origin_stop) { create(:stop, index: 0, hub_id: ocean_origin_hub.id, layovers: [ocean_origin_layover]) }
  let(:ocean_destination_stop) { create(:stop, index: 1, hub_id: ocean_destination_hub.id, layovers: [ocean_destination_layover]) }
  let(:ocean_origin_layover) { create(:layover, stop_index: 0, trip: ocean_trip) }
  let(:ocean_destination_layover) { create(:layover, stop_index: 1, trip: ocean_trip) }

  let!(:air_itinerary) { create(:itinerary, tenant: tenant, stops: [air_origin_stop, air_destination_stop], layovers: [air_origin_layover, air_destination_layover], trips: [air_trip], mode_of_transport: 'air') }
  let(:air_trip) { create(:trip) }
  let(:air_origin_hub) { create(:hub, tenant: tenant, nexus: origin_nexus) }
  let(:air_destination_hub) { create(:hub, tenant: tenant, nexus: destination_nexus) }
  let(:air_origin_stop) { create(:stop, index: 0, hub_id: air_origin_hub.id, layovers: [air_origin_layover]) }
  let(:air_destination_stop) { create(:stop, index: 1, hub_id: air_destination_hub.id, layovers: [air_destination_layover]) }
  let(:air_origin_layover) { create(:layover, stop_index: 0, trip: air_trip) }
  let(:air_destination_layover) { create(:layover, stop_index: 1, trip: air_trip) }

  let!(:rail_itinerary) { create(:itinerary, tenant: tenant, stops: [rail_origin_stop, rail_destination_stop], layovers: [rail_origin_layover, rail_destination_layover], trips: [rail_trip], mode_of_transport: 'rail') }
  let(:rail_trip) { create(:trip) }
  let(:rail_origin_hub) { create(:hub, tenant: tenant, nexus: origin_nexus) }
  let(:rail_destination_hub) { create(:hub, tenant: tenant, nexus: destination_nexus) }
  let(:rail_origin_stop) { create(:stop, index: 0, hub_id: rail_origin_hub.id, layovers: [rail_origin_layover]) }
  let(:rail_destination_stop) { create(:stop, index: 1, hub_id: rail_destination_hub.id, layovers: [rail_destination_layover]) }
  let(:rail_origin_layover) { create(:layover, stop_index: 0, trip: rail_trip) }
  let(:rail_destination_layover) { create(:layover, stop_index: 1, trip: rail_trip) }

  context 'user logged in' do
    let(:pages) do
      {
        'rail' => 1,
        'air' => 1,
        'ocean' => 1
      }
    end

    sign_in(:user)

    context '#tenant_admin_pricings_path' do
      it 'Queries the DB for itineraries, sorted by MOT' do
        get tenant_admin_pricings_path(tenant_id: tenant.id), params: { pages: pages }
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data].dig(:detailedItineraries, :air, 0, :mode_of_transport)).to eq('air')
        expect(json[:data].dig(:detailedItineraries, :rail, 0, :mode_of_transport)).to eq(nil)
        expect(json[:data].dig(:detailedItineraries, :ocean, 0, :mode_of_transport)).to eq('ocean')
        expect(json[:data].dig(:numItineraryPages, :air)).to eq(1)
        expect(json[:data].dig(:numItineraryPages, :rail)).to eq(nil)
        expect(json[:data].dig(:numItineraryPages, :ocean)).to eq(1)
      end
    end

    context '#tenant_admin_pricings_search_path' do
      let(:params) do
        {
          mot: 'ocean',
          text: 'Gothen'
        }
      end

      it 'Queries the DB for itineraries, sorted by MOT' do
        get tenant_admin_search_pricings_path(tenant_id: tenant.id), params: params
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data].dig(:detailedItineraries, 0, :mode_of_transport)).to eq('ocean')
        expect(json[:data].dig(:detailedItineraries, 0, :name)).to eq('Gothenburg - Shanghai')
        expect(json[:data][:numItineraryPages]).to eq(1)
        expect(json[:data][:mode_of_transport]).to eq('ocean')
      end
    end
  end
end
