# frozen_string_literal: true

require 'rails_helper'
require 'active_storage'

RSpec.describe ShippingTools do
  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
  end

  let(:tenant) { create(:tenant) }
  let!(:itinerary) { create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:itinerary_2) { create(:itinerary, tenant: tenant) }
  let(:trip) { create(:trip, itinerary_id: itinerary.id) }
  let(:origin_hub) { Hub.find(itinerary.hubs.find_by(name: 'Gothenburg Port').id) }
  let(:destination_hub) { Hub.find(itinerary.hubs.find_by(name: 'Shanghai Port').id) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { build(:user, tenant: tenant) }
  let(:tenant_vehicle) { create(:tenant_vehicle, tenant: tenant) }
  let(:transport_category) { create(:transport_category, load_type: 'container') }
  let(:shipment) do
    create(:shipment,
           user: user,
           trip: trip,
           tenant: tenant,
           origin_hub: origin_hub,
           destination_hub: destination_hub,
           origin_nexus: origin_hub&.nexus,
           destination_nexus: destination_hub&.nexus)
  end
  let!(:scope) { create(:tenants_scope, target: tenants_tenant, content: { send_email_on_quote_download: true, send_email_on_quote_email: true, base_pricing: true }) }
  let(:schedules) { [Legacy::Schedule.from_trip(trip)] }
  let(:params) do
    {
      shipment_id: shipment.id,
      meta: { tender_id: '123abc' },
      schedule: {
        'trip_id' => trip.id, charge_trip_id: trip.id,
        'origin_hub': origin_hub,
        'destination_hub': destination_hub
      }
    }.with_indifferent_access
  end

  describe '.choose_offer' do
    it 'assigns the id of the chosen tender to the meta data of the shipment' do
      create(:charge_breakdown, shipment: shipment)

      expect { described_class.choose_offer(params, user) }.to change { Shipment.find(shipment.id).meta }.from({}).to('pricing_breakdown' => nil, 'pricing_rate_data' => nil, 'tender_id' => "123abc")
    end
  end

  context 'sending admin emails on quote download/send' do
    let!(:quotation) { create(:quotation, original_shipment_id: shipment.id) }
    let!(:charge_breakdown) { create(:legacy_charge_breakdown, shipment: shipment, trip: trip) }
    let(:results) do
      [
        {
          quote: charge_breakdown.to_nested_hash,
          schedules: [
            {
              'trip_id' => trip.id, charge_trip_id: trip.id,
              'origin_hub': origin_hub,
              'destination_hub': destination_hub
            }
          ],
          meta: { trip_id: trip.id }
        }.with_indifferent_access
      ]
    end

    describe '.save_pdf_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        quote_mailer = double('QuoteMailer')
        allow(quote_mailer).to receive(:deliver_later).and_return(true)
        expect(described_class).to receive(:handle_existing_quote).once.and_return(quotation)
        expect(QuoteMailer).to receive(:quotation_admin_email).once.and_return(quote_mailer)
        expect(quote_mailer).to receive(:deliver_later).once
        result = described_class.save_pdf_quotes(shipment, user.tenant, results)
      end
    end

    describe '.save_and_send_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        quote_mailer = double('QuoteMailer')
        allow(quote_mailer).to receive(:deliver_later).and_return(true)
        expect(described_class).to receive(:handle_existing_quote).once.and_return(quotation)
        expect(QuoteMailer).to receive(:quotation_admin_email).once.and_return(quote_mailer)
        expect(quote_mailer).to receive(:deliver_later).once
        result = described_class.save_and_send_quotes(shipment, results, user.email)
      end
    end
  end

  describe '.request_shipment' do
    it 'persists data into the engine models' do
      cargo_creator = double('Cargo::Creator', errors: [])
      shipment_request_creator = double('Shipments::ShipmentRequestCreator', errors: [])
      shipment_request = double('Shipments::ShipmentRequest', id: 1, tenant_id: 123)

      expect(Cargo::Creator).to receive(:new).with(legacy_shipment: shipment).and_return(cargo_creator)
      expect(cargo_creator).to receive(:perform).once

      expect(Shipments::ShipmentRequestCreator).to receive(:new).with(legacy_shipment: shipment, user: user, sandbox: nil).and_return(shipment_request_creator)
      expect(shipment_request_creator).to receive(:create).once
      expect(shipment_request_creator).to receive(:shipment_request).and_return(shipment_request)

      expect(Integrations::Processor).to receive(:process).once.with(shipment_request_id: 1, tenant_id: 123)

      described_class.request_shipment(params, user)
    end
  end

  describe '.create_shipment' do
    let(:details) { { loadType: 'container', direction: 'export' }.with_indifferent_access }
    let(:current_user) { create(:user, tenant: tenant) }
    let(:itinerary_with_no_pricing) { create(:gothenburg_shanghai_itinerary, tenant: tenant) }

    context 'with base pricing enabled' do
      context 'with :display_itineraries_with_rates in scope' do
        before do
          Pricings::Pricing.create(itinerary: itinerary,
                                   load_type: details[:loadType],
                                   tenant: tenant, user: user,
                                   tenant_vehicle: tenant_vehicle,
                                   internal: false)
          Tenants::Scope.create(target: tenants_tenant, content: { base_pricing: true, display_itineraries_with_rates: true })
        end

        it 'creates the shipment and sends routes matching with valid pricings' do
          result = described_class.create_shipment(details, current_user)
          expect(result['routes']).not_to be_empty
          expect(result['routes'].find { |route| route['itineraryId'] === itinerary.id }).not_to be_nil
          expect(result['routes'].find { |route| route['itineraryId'] === itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context 'closed quotation tool' do
      before { Tenants::Scope.find_by(target_id: tenants_tenant.id).update(content: { closed_quotation_tool: true }) }

      context 'without user agency' do
        before { allow(current_user).to receive(:agency).and_return(nil) }

        it 'raises a NonAgentUser error' do
          expect { described_class.create_shipment(details, current_user) }.to raise_error(ApplicationError)
        end
      end

      context 'with user agency' do
        let(:agency_manager) { create(:user, tenant: tenant) }
        let(:agency) { create(:agency, agency_manager: agency_manager, tenant: tenant) }
        let(:user_within_agency) { create(:user, tenant: tenant, agency: agency) }

        before do
          Legacy::Pricing.create(itinerary: itinerary,
                                 user: agency_manager,
                                 tenant: tenant,
                                 transport_category: transport_category,
                                 tenant_vehicle: tenant_vehicle)
        end

        it 'creates the shipment and filters the routes according to the users agency' do
          result = described_class.create_shipment(details, user_within_agency)
          expect(result['routes']).not_to be_empty
          expect(result['routes'].find { |route| route['itineraryId'] === itinerary.id }).not_to be_nil
        end
      end
    end
  end

  describe '.get_offers' do
    let(:current_user) { create(:user, tenant: tenant) }
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
    let(:params) do
      ActionController::Parameters.new(shipment_id: shipment.id, shipment: shipment_params)
    end

    let(:offer_calculator_double) { double(OfferCalculator::Calculator) }

    describe 'fail cases' do
      before { allow(OfferCalculator::Calculator).to receive(:new).and_return(offer_calculator_double) }

      context 'with a guest user' do
        before do
          Tenants::Scope.find_by(target_id: tenants_tenant.id).update(content: { closed_after_map: true })
          allow(current_user).to receive(:guest).and_return(true)
        end

        it 'raises an Application::NotLoggedInError' do
          expect { described_class.get_offers(params, current_user) }.to raise_error(ApplicationError, 'Please sign in to continue with your booking request.')
        end
      end

      context 'errors from OfferCalculator' do
        let(:offer_calculator_error_map) do
          {
            "OfferCalculator::TruckingTools::LoadMeterageExceeded": 'Your shipment has exceeded the load meterage limits for online booking.',
            "OfferCalculator::Calculator::MissingTruckingData": 'A problem occurred calculating trucking for this shipment',
            "OfferCalculator::Calculator::InvalidPickupAddress": 'Unable to build pickup location from address fields.',
            "OfferCalculator::Calculator::InvalidDeliveryAddress": 'Unable to build delivery location from address fields.',
            "OfferCalculator::Calculator::NoDirectionsFound": 'Unable to determine trucking directions. Please check the address and try again.',
            "OfferCalculator::Calculator::NoRoute": 'No route matches the selected origin and destination.',
            "OfferCalculator::Calculator::InvalidRoutes": ' Exceded maximum total chargeable weight for the modes of transport available in the selected route. ',
            "OfferCalculator::Calculator::NoValidPricings": 'There are no pricings valid for this timeframe.',
            "OfferCalculator::Calculator::NoSchedulesCharges": 'Unable to determine charges.',
            "ArgumentError": 'Something has gone wrong!'
          }
        end
        it 'rescues errors from the offer calculator service and spews the right messages' do
          offer_calculator_error_map.each do |key, message|
            allow(offer_calculator_double).to receive(:perform).and_raise(key.to_s.constantize)
            expect { described_class.get_offers(params, current_user).perform }.to raise_error(ApplicationError, message)
          end
        end
      end
    end

    describe 'success cases' do
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
                       vehicle_name: 'standard'
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

      it 'returns the correct response including the cargo units' do
        result = described_class.get_offers(params, user)
        expect(result[:shipment]).to eq(mock_offer_calculator.shipment)
        expect(result[:originHubs]).to eq(mock_offer_calculator.hubs[:origin])
        expect(result[:destinationHubs]).to eq(mock_offer_calculator.hubs[:destination])
        expect(result[:results]).to eq(mock_offer_calculator.detailed_schedules)
      end
    end
  end

  describe '.update_shipment' do
    let(:current_user) { FactoryBot.create(:user, tenant: tenant) }
    let(:address) { create(:address, country: create(:country)) }
    let(:itinerary_2) { create(:itinerary, tenant: tenant) }
    let(:contact) { create(:contact, user: current_user, address: address) }
    let(:trip) { FactoryBot.create(:trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
    let(:user_params) do
      {
        address: { street: 'Avenyen', streetNumber: '7', zipCode: '', city: 'Gothenburg', country: 'Sweden' },
        contact: { companyName: 'ItsMyCargo', firstName: 'Test2', lastName: 'shipper', email: 'test@itsmycargo.com', phone: '' }
      }
    end
    let(:shipment_data) do
      {
        hsCodes: {},
        hsTexts: {},
        totalGoodsValue: {},
        cargoNotes: {},
        incotermText: 'This is an incoterm text',
        shipper: ActionController::Parameters.new(
          address: { street: 'Brooktorkai', streetNumber: '7', zipCode: '', city: 'Hamburg', country: 'Germany' },
          contact: { companyName: 'ItsMyCargo', firstName: 'Test', lastName: 'shipper', email: 'test@itsmycargo.com', phone: '' }
        ),
        notifyees: [user_params],
        insurance: { isSelected: true },
        customs: { total: { val: 34, currency: 'USD' }, import: { bool: true, value: '22', currency: 'USD' }, export: { bool: true, value: 12, currency: 'USD' } },
        addons: { customs_export_paper: { value: 12, currency: 'USD' } },
        consignee: ActionController::Parameters.new(
          address: { street: 'Avenyen', streetNumber: '7', zipCode: '', city: 'Gothenburg', country: 'Sweden' },
          contact: { companyName: 'ItsMyCargo', firstName: 'Test2', lastName: 'shipper', email: 'test@itsmycargo.com', phone: '' }
        ),
        notes: []
      }
    end
    let(:params) { ActionController::Parameters.new(shipment_id: shipment.id, shipment: shipment_data) }

    before do
      FactoryBot.create(:charge_breakdown, shipment: shipment, trip: trip)
      allow(Address).to receive(:create_and_geocode).and_return(address)
      allow(described_class).to receive(:search_contacts).and_return(contact)
      %w[EUR USD].each do |currency|
        stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=#{currency}")
          .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json, headers: {})
      end
    end

    it 'updates the shipment appropriately with the attributes in the parameters' do
      result = described_class.update_shipment(params, current_user)
      %i[cargoItems containers aggregatedCargo addresses consignee notifyees shipper documents cargoItemTypes shipment].each do |key|
        expect(result.key?(key)).to be(true)
      end
    end
  end

  describe '.choose_offer' do
    let(:params) { {} }
    let(:current_user) { FactoryBot.create(:user, tenant: tenant) }

    context 'when fail cases' do
      context 'with a guest user' do
        before do
          Tenants::Scope.find_by(target_id: tenants_tenant.id).update(content: { closed_after_map: true })
          allow(current_user).to receive(:guest).and_return(true)
        end

        it 'throws an ApplicationError::NotLoggedIn with a guest user' do
          expect { described_class.choose_offer(params, current_user) }.to raise_error(ApplicationError)
        end
      end

      context 'with an invalid shipment_id' do
        it 'raises an ApplicationError::ShipmentNotFound error' do
          expect { described_class.choose_offer({ shipment_id: 5 }, current_user) }.to raise_error(ApplicationError)
        end
      end
    end

    context 'basic flc example' do
      let(:trip) { FactoryBot.create(:trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }
      let(:params) do
        {
          shipment_id: shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(origin_hub: schedule.origin_hub, destination_hub: schedule.destination_hub).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: nil
          }
        }
      end

      before { FactoryBot.create(:charge_breakdown, shipment: shipment) }

      it 'selects an offer for the shipment and assigns a reference number' do
        result = described_class.choose_offer(params, user)
        expect(result[:shipment]['trip_id']).to eq(trip.id)
      end
    end

    context 'basic lcl with documents customs' do
      let(:address) { create(:address) }

      let!(:user_address) { create(:user_addresses, user: user, address: address) }
      let!(:origin_fee) { create(:customs_fee, hub: origin_hub, direction: 'export', tenant_vehicle_id: trip.tenant_vehicle_id) }
      let!(:destination_fee) { create(:customs_fee, hub: destination_hub, direction: 'import', tenant_vehicle_id: trip.tenant_vehicle_id) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }

      let(:lcl_shipment) do
        create(:shipment,
               user: user,
               trip: trip,
               tenant: tenant,
               origin_hub: origin_hub,
               destination_hub: destination_hub,
               origin_nexus: origin_hub&.nexus,
               destination_nexus: destination_hub&.nexus,
               load_type: 'cargo_item',
               trucking: { "pre_carriage": { "truck_type": "default", "trucking_time_in_seconds": 10_000 } }
              )
      end

      let!(:document) { create(:documents, shipment_id: lcl_shipment.id) }

      let(:params) do
        {
          shipment_id: lcl_shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(origin_hub: schedule.origin_hub, destination_hub: schedule.destination_hub).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: nil
          }
        }
      end

      before do
        stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=EUR").
         to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34 } }.to_json, headers: {})

        FactoryBot.create(:charge_breakdown, shipment: lcl_shipment)
      end

      it 'selects an offer for the shipment and assigns a reference number' do
        result = described_class.choose_offer(params, user)
        expect(result[:shipment]['trip_id']).to eq(trip.id)
      end

    end
  end

  describe '.view_more_schedules' do
    let(:trip) { FactoryBot.create(:trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }

    context 'with a positive delta' do
      let(:delta) { 1 }

      it 'generates schedules from trips later than the specified trip' do
        later_trip = Trip.create(itinerary: itinerary_2,
                                 tenant_vehicle: tenant_vehicle,
                                 start_date: trip.start_date + 7,
                                 end_date: trip.end_date + 14)
        result = described_class.view_more_schedules(trip.id, delta)
        expect(result[:schedules].first[:eta].to_date).to eq(later_trip.end_date.to_date)
      end
    end

    context 'with a negative delta' do
      let(:delta) { -1 }

      it 'generates schedules from trips earlier than the specified trip' do
        earlier_trip = Trip.create(itinerary: itinerary_2,
                                   tenant_vehicle: tenant_vehicle,
                                   start_date: trip.start_date - 14,
                                   end_date: trip.end_date - 7)
        result = described_class.view_more_schedules(trip.id, delta)
        expect(result[:schedules].first[:eta].to_date).to eq(earlier_trip.end_date.to_date)
      end
    end

    context 'create_shipment_from_result (FCL)' do
      let(:old_trip) { FactoryBot.create(:trip, itinerary_id: itinerary.id, tenant_vehicle: tenant_vehicle) }
      let(:old_shipment) do
        create(:shipment,
          trip: old_trip,
          origin_hub_id: origin_hub.id,
          destination_hub_id: destination_hub.id,
          with_breakdown: true,
          meta: {}
        )
      end
      let(:quote) { create(:quotation, original_shipment_id: old_shipment.id) }
      let(:new_schedule) { OfferCalculator::Schedule.from_trip(old_trip).to_detailed_hash }
      let(:result) do
        {
          quote: old_shipment.charge_breakdowns.first.to_nested_hash,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {}
          },
          schedules: [new_schedule]
        }.with_indifferent_access
      end

      it 'creates quoted shipments from original shipment and results' do
        new_shipment_saved = described_class.create_shipment_from_result(
          main_quote: quote,
          original_shipment: old_shipment,
          result: result
        )
        expect(new_shipment_saved).to be_truthy
      end
    end

    context 'create_shipment_from_result (LCL)' do
      let(:old_trip) { FactoryBot.create(:trip, itinerary_id: itinerary.id, tenant_vehicle: tenant_vehicle) }
      let(:old_shipment) do
        create(:shipment,
          trip: old_trip,
          origin_hub_id: origin_hub.id,
          destination_hub_id: destination_hub.id,
          with_breakdown: true,
          load_type: 'cargo_item',
          meta: {}
        )
      end
      let!(:metadatum) { create(:pricings_metadatum, tenant: tenants_tenant, charge_breakdown_id: old_shipment.charge_breakdowns.first.id)}
      let(:quote) { create(:quotation, original_shipment_id: old_shipment.id) }
      let(:new_schedule) { OfferCalculator::Schedule.from_trip(old_trip).to_detailed_hash }
      let(:result) do
        {
          quote: old_shipment.charge_breakdowns.first.to_nested_hash,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {}
          },
          schedules: [new_schedule]
        }.with_indifferent_access
      end

      it 'creates quoted shipments from original shipment and results' do
        new_shipment_saved = described_class.create_shipment_from_result(
          main_quote: quote,
          original_shipment: old_shipment,
          result: result
        )
        expect(new_shipment_saved).to be_truthy
      end
    end

    context 'create_shipment_from_result (AGG)' do
      let(:old_trip) { FactoryBot.create(:trip, itinerary_id: itinerary.id, tenant_vehicle: tenant_vehicle) }
      let!(:old_shipment) do
        create(:shipment,
          trip: old_trip,
          origin_hub_id: origin_hub.id,
          destination_hub_id: destination_hub.id,
          load_type: 'cargo_item',
          meta: {},
          with_aggregated_cargo: true
        )
      end
      let(:charge_breakdown) { create(:charge_breakdown, shipment: old_shipment) }
      let!(:metadatum) { create(:pricings_metadatum, tenant: tenants_tenant, charge_breakdown_id: charge_breakdown.id)}
      let(:quote) { create(:quotation, original_shipment_id: old_shipment.id) }
      let(:new_schedule) { OfferCalculator::Schedule.from_trip(old_trip).to_detailed_hash }
      let(:result) do
        {
          quote: charge_breakdown.to_nested_hash,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {}
          },
          schedules: [new_schedule]
        }.with_indifferent_access
      end

      it 'creates quoted shipments from original shipment and results' do
        new_shipment_saved = described_class.create_shipment_from_result(
          main_quote: quote,
          original_shipment: old_shipment,
          result: result
        )
        expect(new_shipment_saved).to be_truthy
      end
    end
  end
end
