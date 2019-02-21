# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/request_spec_helpers'
Dir["#{Rails.root}/spec/support/auxiliary_constants/shipments/*.rb"].each do |file_path|
  require file_path
end

RSpec.describe 'Pricing requests', type: :request do
  let(:tenant) { create(:tenant) }
  let(:role) { create(:role, name: 'admin') }
  let(:user) { create(:user, tenant: tenant, role: role) }

  let!(:ocean_itinerary) { create(:itinerary, :with_trip, tenant: tenant, mode_of_transport: 'ocean') }
  let!(:air_itinerary) { create(:itinerary, :with_trip, tenant: tenant, mode_of_transport: 'air') }
  let!(:rail_itinerary) { create(:itinerary, :with_trip, tenant: tenant, mode_of_transport: 'rail') }

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
