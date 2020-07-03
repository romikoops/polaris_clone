# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shipments::BookingProcessController do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { create(:organizations_user, :with_profile, organization: organization) }
  let(:shipment) {
    create(:legacy_shipment,
      organization: organization,
      trip: trip,
      user: user,
      itinerary: itinerary,
      with_breakdown: true,
      with_tenders: true)
  }
  let(:shipments_shipment) { Shipment.find(shipment.id) }
  let(:itinerary) { create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:trip) { create(:legacy_trip, itinerary: itinerary) }
  let(:shipping_tools_double) { instance_double('ShippingTools') }

  before do
    ::Organizations.current_id = organization.id
    append_token_header

    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    FactoryBot.create(:organizations_theme, organization: organization)
    FactoryBot.create(:legacy_shipment_contact, shipment: shipments_shipment, contact_type: 'shipper')
    FactoryBot.create(:legacy_shipment_contact, shipment: shipments_shipment, contact_type: 'consignee')
    FactoryBot.create(:legacy_shipment_contact, shipment: shipments_shipment, contact_type: 'notifyee')
  end

  describe 'GET #download_shipment' do
    it 'returns an http status of success' do
      get :download_shipment, params: { organization_id: organization, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.dig('data', 'key')).to eq('shipment_recap')
        expect(json_response.dig('data', 'url')).to include("shipment_#{shipment.imc_reference}.pdf?disposition=attachment")
      end
    end
  end

  context 'when sending admin emails on quote download' do
    let(:charge_breakdown) { shipment.charge_breakdowns.first }
    let(:quotes) do
      [
        {
          quote: charge_breakdown.to_nested_hash({}),
          schedules: [
            OfferCalculator::Schedule.from_trip(trip).to_detailed_hash
          ],
          meta: { trip_id: trip.id }
        }.with_indifferent_access
      ]
    end

    before do
      quote_mailer = object_double('Mailer')
      create(:legacy_quotation, user: user, original_shipment_id: shipment.id)
      allow(QuoteMailer).to receive(:quotation_admin_email).at_least(:once).and_return(quote_mailer)
      allow(QuoteMailer).to receive(:quotation_email).at_least(:once).and_return(quote_mailer)
      allow(quote_mailer).to receive(:deliver_later).at_least(:twice)
    end

    describe '.save_and_send_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        post :send_quotes, params: { organization_id: shipment.organization, shipment_id: shipment.id, quotes: quotes }
      end
    end
  end

  describe 'POST #get_offers' do
    let(:itinerary) { create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:trip) { create(:trip, itinerary_id: itinerary.id) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
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
                     origin_hub: { name: origin_hub.name, id: origin_hub.id },
                     destination_hub: { name: destination_hub.name, id: destination_hub.id },
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
      post :get_offers, params: { organization_id: shipment.organization, shipment_id: shipment.id, shipment: shipment_params }

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
      get :refresh_quotes, params: { organization_id: shipment.organization, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.dig('data').length).to eq(1)
        expect(json_response.dig('data', 0, 'quote', 'total', 'value')).to eq('9.99')
      end
    end
  end

  describe 'POST #choose_offer' do
    before do
      allow(ShippingTools).to receive(:new).and_return(shipping_tools_double)
      allow(shipping_tools_double).to receive(:choose_offer).and_return({shipment: shipment.as_json})
    end

    it 'returns an http status of success' do
      post :choose_offer, params: { organization_id: shipment.organization, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #update_shipment' do
    before do
      allow(ShippingTools).to receive(:new).and_return(shipping_tools_double)
      allow(shipping_tools_double).to receive(:update_shipment).and_return({shipment: shipment.as_json})
    end

    it 'returns an http status of success' do
      post :update_shipment, params: { organization_id: shipment.organization, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #request_shipment' do
    before do
      allow(ShippingTools).to receive(:new).and_return(shipping_tools_double)
      allow(shipping_tools_double).to receive(:request_shipment).and_return(shipment)
      allow(shipping_tools_double).to receive(:tenant_notification_email).and_return(true)
      allow(shipping_tools_double).to receive(:shipper_notification_email).and_return(true)
    end

    it 'returns an http status of success' do
      post :request_shipment, params: { organization_id: shipment.organization, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create_shipment' do

    it 'returns an http status of success' do
      post :create_shipment, params: { organization_id: shipment.organization, details: {loadType: 'cargo_item', direction: 'import'} }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json.dig(:data, :shipment, :id)).to be_present
      end
    end
  end
end
