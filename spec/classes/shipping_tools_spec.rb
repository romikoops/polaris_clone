# frozen_string_literal: true

require 'rails_helper'
require 'active_storage'

RSpec.describe ShippingTools do
  before do
    ::Organizations.current_id = organization.id
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
  end

  let!(:organization) { create(:organizations_organization) }
  let!(:itinerary) { create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:itinerary_2) { create(:hamburg_shanghai_itinerary, organization: organization) }
  let(:trip) { create(:trip, itinerary_id: itinerary.id) }
  let(:origin_hub) { Hub.find(itinerary.hubs.find_by(name: 'Gothenburg').id) }
  let(:destination_hub) { Hub.find(itinerary.hubs.find_by(name: 'Shanghai').id) }
  let!(:scope) { create(:organizations_scope, target: organization, content: { send_email_on_quote_download: true, send_email_on_quote_email: true, base_pricing: true }) }
  let(:user) { create(:organizations_user, :with_profile, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group, name: 'Test', organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:hidden_args) { Pdf::HiddenValueService.new(user: user).hide_total_args }
  let(:args) { Pdf::HiddenValueService.new(user: user).hide_total_args }
  let(:tenant_vehicle) { create(:tenant_vehicle, organization: organization) }
  let(:shipment) do
    create(:legacy_shipment,
           user: user,
           trip: trip,
           organization: organization,
           origin_hub: origin_hub,
           destination_hub: destination_hub,
           origin_nexus: origin_hub&.nexus,
           destination_nexus: destination_hub&.nexus)
  end
  let(:schedules) { [Legacy::Schedule.from_trip(trip)] }
  let(:tender_id) { SecureRandom.uuid }
  let(:params) do
    {
      shipment_id: shipment.id,
      meta: { tender_id: tender_id },
      schedule: {
        'trip_id' => trip.id, charge_trip_id: trip.id,
        'origin_hub': origin_hub,
        'destination_hub': destination_hub
      }
    }.with_indifferent_access
  end

  context 'when sending admin emails on quote download' do
    let(:shipment) do
      create(:legacy_shipment,
             user: user,
             trip: trip,
             organization: organization,
             origin_hub: origin_hub,
             destination_hub: destination_hub,
             origin_nexus: origin_hub&.nexus,
             destination_nexus: destination_hub&.nexus,
             with_breakdown: true,
             with_tenders: true)
    end
    let!(:charge_breakdown) { shipment.charge_breakdowns.first }
    let(:results) do
      [
        {
          quote: charge_breakdown.to_nested_hash(args, sub_total_charge: false),
          schedules: [
            {
              'trip_id' => charge_breakdown.trip_id, charge_trip_id: charge_breakdown.trip_id,
              'origin_hub': origin_hub,
              'destination_hub': destination_hub
            }
          ],
          meta: { charge_trip_id: trip.id }
        }.with_indifferent_access
      ]
    end

    before do
      quote_mailer = object_double('Mailer')
      create(:legacy_quotation, original_shipment: shipment)
      FactoryBot.create(:legacy_content, component: 'WelcomeMail', section: 'subject', text: 'WELCOME_EMAIL', organization_id: organization.id)
      allow(QuoteMailer).to receive(:quotation_admin_email).at_least(:once).and_return(quote_mailer)
      allow(QuoteMailer).to receive(:quotation_email).at_least(:once).and_return(quote_mailer)
      allow(quote_mailer).to receive(:deliver_later).at_least(:twice)
      FactoryBot.create(:organizations_theme, organization: organization)
    end

    describe '.save_pdf_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        described_class.new.save_pdf_quotes(shipment, user.organization, results)
      end
    end

    describe '.save_and_send_quotes' do
      it 'successfully calls the mailer and return the quote Document' do
        described_class.new.save_and_send_quotes(shipment, results, user.email)
      end
    end
  end

  describe '.request_shipment' do
    before do
      cargo_creator = instance_double('Cargo::Creator', errors: [])
      shipment_request_creator = instance_double('Shipments::ShipmentRequestCreator', errors: [])
      shipment_request = instance_double('Shipments::ShipmentRequest', id: 1, organization_id: 123)
      allow(Cargo::Creator).to receive(:new).with(legacy_shipment: shipment).and_return(cargo_creator)
      allow(cargo_creator).to receive(:perform).once
      allow(Shipments::ShipmentRequestCreator).to receive(:new).with(legacy_shipment: shipment, user: user, sandbox: nil).and_return(shipment_request_creator)
      allow(shipment_request_creator).to receive(:create).once
      allow(shipment_request_creator).to receive(:shipment_request).and_return(shipment_request)
      allow(Integrations::Processor).to receive(:process).once.with(shipment_request_id: 1, organization_id: 123)
    end

    it 'persists data into the engine models' do
      described_class.new.request_shipment(params, user)
    end
  end

  describe '.create_shipment' do
    let(:details) { { loadType: 'container', direction: 'export' }.with_indifferent_access }

    before { ::Organizations.current_id = organization.id }

    context 'with base pricing  && display_itineraries_with_rates enabled' do
      let!(:itinerary_with_no_pricing) { create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
                          itinerary: itinerary,
                          cargo_class: 'fcl_20',
                          load_type: details[:loadType],
                          organization: organization, group_id: group.id,
                          tenant_vehicle: tenant_vehicle,
                          internal: false)
        scope.update(content: { base_pricing: true, display_itineraries_with_rates: true })
      end

      it 'creates the shipment and sends routes matching with valid pricings' do
        result = described_class.new.create_shipment(details, user)
        aggregate_failures do
          expect(result['routes']).not_to be_empty
          expect(result['routes'].find { |route| route['itineraryId'] == itinerary.id }).not_to be_nil
          expect(result['routes'].find { |route| route['itineraryId'] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context 'with base pricing  && display_itineraries_with_rates enabled && user margins' do
      let!(:itinerary_with_no_pricing) { create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
                          itinerary: itinerary,
                          cargo_class: 'fcl_20',
                          load_type: details[:loadType],
                          organization: organization, group_id: group.id,
                          tenant_vehicle: tenant_vehicle,
                          internal: false)
        FactoryBot.create(:pricings_margin, applicable: group, organization: organization)
        scope.update(content: { base_pricing: true, display_itineraries_with_rates: true })
      end

      it 'creates the shipment and sends routes matching with valid pricings' do
        result = described_class.new.create_shipment(details, user)
        aggregate_failures do
          expect(result['routes']).not_to be_empty
          expect(result['routes'].find { |route| route['itineraryId'] == itinerary.id }).not_to be_nil
          expect(result['routes'].find { |route| route['itineraryId'] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context 'with base pricing  && expired rates' do
      let(:itinerary_with_expired_pricing) { create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
                          itinerary: itinerary,
                          cargo_class: 'fcl_20',
                          load_type: details[:loadType],
                          organization: organization, group_id: group.id,
                          tenant_vehicle: tenant_vehicle,
                          internal: false)
        FactoryBot.create(:pricings_pricing,
                          itinerary: itinerary_with_expired_pricing,
                          cargo_class: 'fcl_20',
                          load_type: details[:loadType],
                          organization: organization, group_id: group.id,
                          tenant_vehicle: tenant_vehicle,
                          internal: false,
                          expiration_date: Time.zone.today - 1.day,
                          effective_date: Time.zone.today - 10.days)
      end

      it 'creates the shipment and sends routes matching with valid pricings' do
        result = described_class.new.create_shipment(details, user)
        aggregate_failures do
          expect(result['routes']).not_to be_empty
          expect(result['routes'].find { |route| route['itineraryId'] == itinerary.id }).not_to be_nil
          expect(result['routes'].find { |route| route['itineraryId'] == itinerary_with_expired_pricing.id }).to be_nil
        end
      end
    end
  end

  describe '.get_offers' do
    let(:current_user) { create(:organizations_user, organization: organization) }
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
        selected_day: Time.zone.today,
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

    let(:offer_calculator_double) { instance_double(OfferCalculator::Calculator) }

    before do
      allow(OfferCalculator::Calculator).to receive(:new).and_return(offer_calculator_double)
    end

    context 'when failing with a guest user' do
      before do
        Organizations::Scope.find_by(target_id: organization.id).update(content: { closed_after_map: true, base_pricing: true })
      end

      let(:current_user) { nil }

      it 'raises an Application::NotLoggedInError' do
        expect { described_class.new.get_offers(params, nil) }.to raise_error(ApplicationError, 'Please sign in to continue with your booking request.')
      end
    end

    context 'when failing in OfferCalculator' do
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
          "OfferCalculator::Calculator::NoValidSchedules": 'There are no departures for this timeframe.',
          "OfferCalculator::Calculator::InvalidLocalChargeResult": 'The system was unable to calculate a valid set of local charges for this booking.',
          "OfferCalculator::Calculator::InvalidFreightResult": 'The system was unable to calculate a valid set of freight charges for this booking.',
          "ArgumentError": 'Something has gone wrong!'
        }
      end

      it 'rescues errors from the offer calculator service and spews the right messages' do
        offer_calculator_error_map.each do |key, message|
          allow(offer_calculator_double).to receive(:perform).and_raise(key.to_s.constantize)
          expect { described_class.new.get_offers(params, current_user).perform }.to raise_error(ApplicationError, message)
        end
      end
    end

    describe 'success cases' do
      let(:mock_offer_calculator) do
        instance_double('OfferCalculator::Calculator',
                        shipment: shipment,
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
                                eta: Time.zone.today + 40,
                                etd: Time.zone.today,
                                closing_date: Time.zone.today + 20,
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
      let(:tender) {
        FactoryBot.create(:quotations_tender,
          origin_hub: origin_hub,
          destination_hub: destination_hub)
      }

      before do
        create(:charge_breakdown, shipment: shipment, trip: trip, tender: tender)
        allow(OfferCalculator::Calculator).to receive(:new).and_return(mock_offer_calculator)
        allow(mock_offer_calculator).to receive(:perform)
        allow(QuotedShipmentsJob).to receive(:perform_later)
      end

      it 'returns the correct response including the cargo units' do
        result = described_class.new.get_offers(params, user)
        aggregate_failures do
          expect(result[:shipment]).to eq(mock_offer_calculator.shipment)
          expect(result[:originHubs]).to eq(mock_offer_calculator.hubs[:origin])
          expect(result[:destinationHubs]).to eq(mock_offer_calculator.hubs[:destination])
          expect(result[:results]).to eq(mock_offer_calculator.detailed_schedules)
        end
      end

      it 'returns the correct response including the cargo units for a quote setup' do
        Organizations::Scope.find_by(target_id: organization.id)
          .update(content: { closed_quotation_tool: true, email_all_quotes: true })

        result = described_class.new.get_offers(params, user)
        aggregate_failures do
          expect(result[:shipment]).to eq(mock_offer_calculator.shipment)
          expect(result[:originHubs]).to eq(mock_offer_calculator.hubs[:origin])
          expect(result[:destinationHubs]).to eq(mock_offer_calculator.hubs[:destination])
          expect(result[:results]).to eq(mock_offer_calculator.detailed_schedules)
        end
      end

      context 'with trucking, quote and breakdowns' do
        before do
          shipment.update(trucking: { 'pre_carriage' => { 'truck_type' => 'default', 'trucking_time_in_seconds' => 10_000 } })
          FactoryBot.create(:pricings_metadatum, charge_breakdown: shipment.charge_breakdowns.first, organization: organization)
        end

        it 'returns the correct response including the cargo units for a quote setup with trucking' do
          Organizations::Scope.find_by(target_id: organization.id).update(content: { closed_quotation_tool: true })

          result = described_class.new.get_offers(params, user)
          aggregate_failures do
            expect(result[:shipment]).to eq(mock_offer_calculator.shipment)
            expect(result[:originHubs]).to eq(mock_offer_calculator.hubs[:origin])
            expect(result[:destinationHubs]).to eq(mock_offer_calculator.hubs[:destination])
            expect(result[:results]).to eq(mock_offer_calculator.detailed_schedules)
          end
        end
      end
    end
  end

  describe '.update_shipment' do
    let(:current_user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:address) { create(:address, country: create(:country)) }
    let(:itinerary_2) { create(:itinerary, name: 'A - B', organization: organization) }
    let(:contact) { create(:contact, user: current_user, address: address) }
    let(:trip) { FactoryBot.create(:trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
    let(:user_params) do
      {
        address: { street: 'Avenyen', streetNumber: '7', zipCode: '', city: 'Gothenburg', country: 'Sweden' },
        contact: { companyName: 'ItsMyCargo', firstName: 'Test2', lastName: 'shipper', email: 'test@itsmycargo.com', phone: '123' }
      }
    end
    let(:shipment) do
      create(:legacy_shipment,
             user: user,
             trip: trip,
             organization: organization,
             origin_hub: origin_hub,
             destination_hub: destination_hub,
             origin_nexus: origin_hub&.nexus,
             destination_nexus: destination_hub&.nexus,
             with_tenders: true,
             with_breakdown: true,
             total_goods_value: {currency: 'USD', value: '1000.00'})
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
          contact: { companyName: 'ItsMyCargo', firstName: 'Test', lastName: 'shipper', email: 'shipper_test@itsmycargo.com', phone: '123' }
        ),
        notifyees: [user_params],
        insurance: { isSelected: true, val: 1000 },
        customs: { total: { val: 34, currency: 'USD' }, import: { bool: true, val: '22', currency: 'USD' }, export: { bool: true, val: 12, currency: 'USD' } },
        addons: { customs_export_paper: { value: 12, currency: 'USD' } },
        consignee: ActionController::Parameters.new(
          address: { street: 'Avenyen', streetNumber: '7', zipCode: '', city: 'Gothenburg', country: 'Sweden' },
          contact: { companyName: 'ItsMyCargo', firstName: 'Test2', lastName: 'shipper', email: 'consignee_test@itsmycargo.com', phone: '123' }
        ),
        notes: []
      }
    end
    let(:params) { ActionController::Parameters.new(shipment_id: shipment.id, shipment: shipment_data) }
    let(:contact_params) do
      ActionController::Parameters.new(
        address: { street: 'Brooktorkai', streetNumber: '7', zipCode: '', city: 'Hamburg', country: 'Germany' },
        contact: {
          companyName: 'ItsMyCargo',
          firstName: 'Test',
          lastName: 'shipper',
          email: 'shipper_test@itsmycargo.com',
          phone: '123'
        }
      )
    end
    let(:expected_keys) {
      %i[cargoItems
        containers
        aggregatedCargo
        addresses
        consignee
        notifyees
        shipper
        documents
        cargoItemTypes
        shipment]
    }
    let(:tender) { shipment.charge_breakdowns.selected.tender }

    before do
      FactoryBot.create(:legacy_file, :with_file, shipment: shipment, doc_type: 'packing_sheet')
      allow(Address).to receive(:create_and_geocode).and_return(address)
    end

    it 'updates the shipment appropriately with the attributes in the parameters' do
      result = described_class.new.update_shipment(params, current_user)
      aggregate_failures do
        expected_keys.each do |key|
          expect(result.key?(key)).to be(true)
        end
        expect(tender.line_items.where(section: :insurance_section).count).to eq(1)
        expect(tender.line_items.where(section: :insurance_section).map(&:code)).to eq(["freight_insurance"])
        expect(tender.line_items.where(section: :customs_section).count).to eq(2)
        expect(
          tender.line_items.where(section: :customs_section).map(&:code)
        ).to match_array(["export_customs", "import_customs"])
        expect(tender.line_items.where(section: :addons_section).count).to eq(1)
      end
    end

    it 'does not allow shipper and consignee to be the same contact' do
      params = ActionController::Parameters.new(shipment_id: shipment.id, shipment: {
                                                  shipper: contact_params,
                                                  consignee: contact_params
                                                })
      expect { described_class.new.update_shipment(params, current_user) }.to raise_error(ApplicationError)
    end
  end

  describe '.choose_offer' do
    let(:params) { {} }
    let(:current_user) { FactoryBot.create(:organizations_user, organization: organization) }

    context 'when failing with a guest user' do
      before do
        Organizations::Scope.find_by(target_id: organization.id).update(content: { closed_after_map: true })
        current_user = nil
      end

      it 'throws an ApplicationError::NotLoggedIn with a guest user' do
        expect { described_class.new.choose_offer(params, current_user) }.to raise_error(ApplicationError)
      end
    end

    context 'when failing with an invalid shipment_id' do
      it 'raises an ApplicationError::ShipmentNotFound error' do
        expect { described_class.new.choose_offer({ shipment_id: 5 }, current_user) }.to raise_error(ApplicationError)
      end
    end

    context 'when basic fcl example' do
      let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }
      let(:params) do
        {
          shipment_id: shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(
            origin_hub: schedule.origin_hub,
            destination_hub: schedule.destination_hub,
            charge_trip_id: schedule.trip_id
          ).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: nil
          }
        }
      end

      before { FactoryBot.create(:charge_breakdown, shipment: shipment, tender_id: tender_id) }

      it 'selects an offer for the shipment and assigns a reference number' do
        result = described_class.new.choose_offer(params, user)
        aggregate_failures do
          expect(result[:shipment]['trip_id']).to eq(trip.id)
          expect(result[:shipment]['tender_id']).to eq(tender_id)
        end
      end
    end

    context 'when it is a basic lcl with documents customs' do
      let(:address) { create(:address) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }
      let(:lcl_shipment) do
        create(:shipment,
               user: user,
               trip: trip,
               organization: organization,
               origin_hub: origin_hub,
               destination_hub: destination_hub,
               origin_nexus: origin_hub&.nexus,
               destination_nexus: destination_hub&.nexus,
               load_type: 'cargo_item',
               trucking: { "pre_carriage": { "truck_type": 'default', "trucking_time_in_seconds": 10_000 } })
      end
      let(:params) do
        {
          shipment_id: lcl_shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(
            origin_hub: schedule.origin_hub,
            destination_hub: schedule.destination_hub,
            charge_trip_id: schedule.trip_id
          ).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: nil
          }
        }
      end

      before do
        create(:user_addresses, user: user, address: address)
        create(:customs_fee, hub: origin_hub, direction: 'export', tenant_vehicle_id: trip.tenant_vehicle_id)
        create(:customs_fee, hub: destination_hub, direction: 'import', tenant_vehicle_id: trip.tenant_vehicle_id)
        create(:legacy_file, shipment_id: lcl_shipment.id)
        stub_request(:get, 'http://data.fixer.io/latest?access_key=FAKEKEY&base=EUR')
          .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34 } }.to_json, headers: {})
        FactoryBot.create(:charge_breakdown, shipment: lcl_shipment)
      end

      it 'selects an offer for the shipment and assigns a reference number' do
        result = described_class.new.choose_offer(params, user)
        expect(result[:shipment]['trip_id']).to eq(trip.id)
      end
    end
  end

  describe '.view_more_schedules' do
    let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }

    context 'with a positive delta' do
      let(:delta) { 1 }
      let!(:later_trip) do
        create(:legacy_trip, itinerary: itinerary_2,
                             tenant_vehicle: tenant_vehicle,
                             start_date: trip.start_date + 7,
                             end_date: trip.end_date + 14)
      end

      it 'generates schedules from trips later than the specified trip' do
        result = described_class.new.view_more_schedules(trip.id, delta)
        expect(result[:schedules].first[:eta].to_date).to eq(later_trip.end_date.to_date)
      end
    end

    context 'with a negative delta' do
      let(:delta) { -1 }
      let!(:earlier_trip) do
        create(:legacy_trip, itinerary: itinerary_2,
                             tenant_vehicle: tenant_vehicle,
                             start_date: trip.start_date - 14,
                             end_date: trip.end_date - 7)
      end

      it 'generates schedules from trips earlier than the specified trip' do
        result = described_class.new.view_more_schedules(trip.id, delta)
        expect(result[:schedules].first[:eta].to_date).to eq(earlier_trip.end_date.to_date)
      end
    end
  end

  describe '.shipper_welcome_email' do
    context 'with content' do
      before do
        welcome_mailer = double('WelcomeMailer', deliver_later: true)
        FactoryBot.create(:legacy_content, component: 'WelcomeMail', section: 'subject', text: 'WELCOME_EMAIL', organization_id: organization.id)
        allow(WelcomeMailer).to receive(:welcome_email).at_least(:once).and_return(welcome_mailer)
        allow(welcome_mailer).to receive(:deliver_later)
      end

      it 'calls the mailer when content is available' do
        described_class.new.shipper_welcome_email(user)
      end
    end
  end
end
