# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shipments::BookingProcessController do
  let(:tenant) { create(:legacy_tenant) }
  let(:shipment) { create(:complete_legacy_shipment, tenant: tenant, with_breakdown: true) }
  let(:user) { create(:legacy_user, tenant: tenant) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    %w[EUR USD].each do |currency|
      stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=#{currency}")
        .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34 } }.to_json, headers: {})
    end
  end

  describe 'GET #download_shipment' do
    it 'returns an http status of success' do
      get :download_shipment, params: { tenant_id: shipment.tenant, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.dig('data', 'key')).to eq('shipment_recap')
        expect(json_response.dig('data', 'url')).to include("shipment_#{shipment.imc_reference}.pdf?disposition=attachment")
      end
    end
  end

  describe 'POST #get_offers' do
    let(:itinerary) { create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:trip) { create(:trip, itinerary_id: itinerary.id) }
    let(:origin_hub) { Hub.find(itinerary.hubs.find_by(name: 'Gothenburg Port').id) }
    let(:destination_hub) { Hub.find(itinerary.hubs.find_by(name: 'Shanghai Port').id) }
    let(:shipment_params) do
      shipment.as_json.merge(
        origin: {
          longitude: origin_hub.longitude,
          latitude: origin_hub.latitude,
          nexus_id: origin_hub.nexus.id,
          nexus_name: origin_hub.nexus.name,
          country: origin_hub.nexus.country.name
        },
        destination: {
          longitude: destination_hub.longitude,
          latitude: destination_hub.latitude,
          nexus_id: destination_hub.nexus.id,
          nexus_name: destination_hub.nexus.name,
          country: destination_hub.nexus.country.name
        },
        direction: 'export',
        selected_day: Date.today,
        containers_attributes: [{
          size_class: 'fcl_40',
          quantity: 1,
          payload_in_kg: 12,
          dangerous_goods: false
        }]
      )
    end
    let(:offer_calculator_double) { double(OfferCalculator::Calculator) }
    let(:mock_offer_calculator) do
      double(shipment: shipment,
             detailed_schedules: [
               {
                 quote: {
                   total: { value: '1220.0', currency: 'USD' },
                   name: 'Grand Total'
                 },
                 schedules: [
                   {
                     id: '71ad5e38-5e98-4f54-9007-d4a4a258b998',
                     origin_hub: { name: origin_hub.name },
                     destination_hub: { name: destination_hub.name },
                     mode_of_transport: 'ocean',
                     eta: Date.today + 40,
                     etd: Date.today,
                     closing_date: Date.today + 20,
                     vehicle_name: 'standard',
                     trip_id: trip.id
                   }
                 ],
                 meta: {
                   load_type: 'container',
                   mode_of_transport: 'ocean',
                   name: 'Gothenburg - Shanghai',
                   service_level: 'standard',
                   origin_hub: origin_hub.as_json.with_indifferent_access,
                   itinerary_id: itinerary.id,
                   destination_hub: destination_hub.as_json.with_indifferent_access,
                   service_level_count: 2,
                   pricing_rate_data: {
                     fcl_20: {
                       BAS: {
                         rate: '1220.0',
                         rate_basis: 'PER_CONTAINER',
                         currency: 'USD',
                         min: '1220.0'
                       },
                       total: {
                         value: '1220.0',
                         currency: 'USD'
                       }
                     }
                   }
                 }
               }
             ],
             hubs: {
               origin: [origin_hub],
               destination: [destination_hub]
             })
    end

    before do
      allow(OfferCalculator::Calculator).to receive(:new).and_return(mock_offer_calculator)
      allow(mock_offer_calculator).to receive(:perform)
    end

    it 'returns an http status of success' do
      post :get_offers, params: { tenant_id: shipment.tenant, shipment_id: shipment.id, shipment: shipment_params }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        data = JSON.parse(json_response['data'])
        expect(data.dig('shipment', 'id')).to eq(shipment.id)
        expect(data['results'].length).to eq(1)
      end
    end
  end

  describe 'GET #refresh_quotes' do
    it 'returns an http status of success' do
      get :refresh_quotes, params: { tenant_id: shipment.tenant, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.dig('data').length).to eq(1)
        expect(json_response.dig('data', 0, 'quote', 'total', 'value')).to eq('9.99')
      end
    end
  end
end
