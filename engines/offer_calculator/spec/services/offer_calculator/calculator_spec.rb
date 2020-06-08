# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Calculator do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }

  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant) }
  let(:air_itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, mode_of_transport: 'air', tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:origin_airport) { air_itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:destination_airport) { air_itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:hamburg_address) { FactoryBot.create(:hamburg_address) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:pickup_address) { FactoryBot.create(:hamburg_address) }
  let(:delivery_address) { FactoryBot.create(:shanghai_address) }
  let(:base_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      destination_hub: nil,
                      origin_hub: nil,
                      desired_start_date: Time.zone.today + 4.days,
                      user: user,
                      tenant: tenant)
  end
  let(:trip_itineraries) { [itinerary, air_itinerary] }

  let(:trips) do
    trip_itineraries.flat_map do |it|
      [
        FactoryBot.create(:trip_with_layovers, itinerary: it, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle),
        FactoryBot.create(:trip_with_layovers,
                          itinerary: it,
                          load_type: 'cargo_item',
                          tenant_vehicle: tenant_vehicle,
                          closing_date: 5.days.from_now,
                          start_date: 10.days.from_now,
                          end_date: 30.days.from_now)
      ]
    end
  end

  let(:cargo_item_attributes) do
    [
      {
        'payload_in_kg' => 120,
        'total_volume' => 0,
        'total_weight' => 0,
        'width' => 120,
        'length' => 80,
        'height' => 120,
        'quantity' => 1,
        'cargo_item_type_id' => pallet.id,
        'dangerous_goods' => false,
        'stackable' => true
      }
    ]
  end

  let(:aggregated_cargo_attributes) do
    {
      'volume' => 2.0,
      'weight' => 1000
    }
  end

  let(:container_attributes) do
    [
      {
        'payload_in_kg' => 12_000,
        'size_class' => 'fcl_20',
        'quantity' => 1,
        'dangerous_goods' => false
      },
      {
        'payload_in_kg' => 12_000,
        'size_class' => 'fcl_40',
        'quantity' => 1,
        'dangerous_goods' => false
      },
      {
        'payload_in_kg' => 12_000,
        'size_class' => 'fcl_40_hq',
        'quantity' => 1,
        'dangerous_goods' => false
      }
    ]
  end

  let(:params) do
    {
      shipment: {
        'id' => base_shipment.id,
        'direction' => 'export',
        'selected_day' => 4.days.from_now.beginning_of_day.to_s,
        'cargo_items_attributes' => [],
        'containers_attributes' => [],
        'trucking' => {
          'pre_carriage' => { 'truck_type' => '' },
          'on_carriage' => { 'truck_type' => '' }
        },
        'incoterm' => {},
        'aggregated_cargo_attributes' => nil
      }
    }
  end

  let(:pickup_location) { FactoryBot.create(:trucking_location, zipcode: pickup_address.zip_code, country_code: pickup_address.country.code) }
  let(:delivery_location) { FactoryBot.create(:trucking_location, zipcode: delivery_address.zip_code, country_code: delivery_address.country.code) }
  let(:quotation) { Quotations::Quotation.first }
  let(:zipcode_pre_availability) { FactoryBot.create(:trucking_type_availability, query_method: :zipcode, carriage: 'pre', load_type: 'cargo_item') }
  let(:zipcode_on_availability) { FactoryBot.create(:trucking_type_availability, query_method: :zipcode, carriage: 'on', load_type: 'cargo_item') }

  before do
    [origin_airport, origin_hub].each do |hub|
      FactoryBot.create(:trucking_hub_availability, hub: hub, type_availability: zipcode_pre_availability)
      FactoryBot.create(:trucking_trucking,
                        hub: hub,
                        tenant: tenant,
                        location: pickup_location)
    end
    [destination_airport, destination_hub].each do |hub|
      FactoryBot.create(:trucking_hub_availability, hub: hub, type_availability: zipcode_on_availability)
      FactoryBot.create(:trucking_trucking,
                        hub: hub,
                        tenant: tenant,
                        carriage: 'on',
                        location: delivery_location)
    end
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:lcl_pricing, itinerary: air_itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_local_charge, tenant: tenant, hub: origin_hub, tenant_vehicle: tenant_vehicle, direction: 'export')
    FactoryBot.create(:legacy_local_charge, tenant: tenant, hub: destination_hub, tenant_vehicle: tenant_vehicle, direction: 'import')
    FactoryBot.create(:legacy_local_charge, tenant: tenant, hub: origin_airport, mode_of_transport: 'air', tenant_vehicle: tenant_vehicle, direction: 'export')
    FactoryBot.create(:legacy_local_charge, tenant: tenant, hub: destination_airport, mode_of_transport: 'air', tenant_vehicle: tenant_vehicle, direction: 'import')
    FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
    stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
      .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26, SEK: 8.26 } }.to_json, headers: {})
    %w[ocean trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
    trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) }
  end

  context 'with port to port' do
    let(:port_to_port_params) do
      params[:shipment]['origin'] = {
        'latitude' => origin_hub.latitude,
        'longitude' => origin_hub.longitude,
        'nexus_id' => origin_hub.nexus_id,
        'nexus_name' => origin_hub.nexus.name,
        'country' => origin_hub.nexus.country.code
      }
      params[:shipment]['destination'] = {
        'latitude' => destination_hub.latitude,
        'longitude' => destination_hub.longitude,
        'nexus_id' => destination_hub.nexus_id,
        'nexus_name' => destination_hub.nexus.name,
        'country' => destination_hub.nexus.country.code
      }
      params[:shipment]['cargo_items_attributes'] = cargo_item_attributes
      ActionController::Parameters.new(params)
    end
    let(:service) { described_class.new(shipment: base_shipment, params: port_to_port_params, user: user, sandbox: nil) }

    describe '.perform' do
      it 'perform a booking calulation' do
        results = service.perform
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(28.8)
          expect(Quotations::Quotation.count).to be(1)
        end
      end

      it 'perform a quote calulation' do
        port_to_port_params['shipment']['isQuote'] = true
        results = service.perform
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(28.8)
          expect(Quotations::Quotation.count).to be(1)
        end
      end
    end

    describe '.perform with transshipments' do
      let(:transshipment_itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant, transshipment: 'ZACPT') }
      let!(:transshipment_pricing) { FactoryBot.create(:lcl_pricing, itinerary: transshipment_itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle, transshipment: 'ZACPT') }
      let(:trip_itineraries) { [itinerary, air_itinerary, transshipment_itinerary] }

      it 'perform a booking calulation' do
        results = service.perform
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(28.8)
          expect(results.map { |result| result.dig(:meta, :transshipmentVia) }).to match_array([nil, transshipment_pricing.transshipment])
          expect(Quotations::Quotation.count).to be(1)
        end
      end
    end
  end

  context 'with door to door' do
    let(:trucking_shipment) do
      FactoryBot.create(:legacy_shipment,
                        load_type: 'cargo_item',
                        destination_hub: nil,
                        origin_hub: nil,
                        desired_start_date: Time.zone.today + 4.days,
                        user: user,
                        trucking: {
                          pre_carriage: {
                            address_id: pickup_address.id,
                            truck_type: 'default'
                          },
                          on_carriage: {
                            address_id: delivery_address.id,
                            truck_type: 'default'
                          }
                        },
                        tenant: tenant)
    end
    let(:port_to_port_params) do
      params[:shipment]['trucking'] = {
        pre_carriage: {
          address_id: pickup_address.id,
          truck_type: 'default'
        },
        on_carriage: {
          address_id: delivery_address.id,
          truck_type: 'default'
        }
      }
      params[:shipment]['origin'] = {
        'latitude' => pickup_address.latitude,
        'longitude' => pickup_address.longitude,
        'nexus_id' => origin_hub.nexus_id,
        'nexus_name' => origin_hub.nexus.name,
        'country' => origin_hub.nexus.country.code
      }
      params[:shipment]['destination'] = {
        'latitude' => delivery_address.latitude,
        'longitude' => delivery_address.longitude,
        'nexus_id' => destination_hub.nexus_id,
        'nexus_name' => destination_hub.nexus.name,
        'country' => destination_hub.nexus.country.code
      }
      params[:shipment]['cargo_items_attributes'] = cargo_item_attributes
      ActionController::Parameters.new(params)
    end
    let(:origin_address_params) do
      {
        latitude: pickup_address.latitude,
        longitude: pickup_address.longitude,
        zip_code: pickup_address.zip_code,
        country: pickup_address.country.name,
        geocoded_address: pickup_address.geocoded_address,
        street_number: pickup_address.street_number,
        sandbox: nil
      }.with_indifferent_access
    end
    let(:destination_address_params) do
      {
        latitude: delivery_address.latitude,
        longitude: delivery_address.longitude,
        zip_code: delivery_address.zip_code,
        country: delivery_address.country.name,
        geocoded_address: delivery_address.geocoded_address,
        street_number: delivery_address.street_number,
        sandbox: nil
      }.with_indifferent_access
    end
    let(:service) { described_class.new(shipment: trucking_shipment, params: port_to_port_params, user: user, sandbox: nil) }

    before do
      allow_any_instance_of(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:address_params).with(:origin).and_return(origin_address_params)
      allow_any_instance_of(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:address_params).with(:destination).and_return(destination_address_params)
      allow_any_instance_of(OfferCalculator::Service::TruckingDataBuilder).to receive(:calc_distance).and_return(10)
      allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
    end

    describe '.perform' do
      let!(:results) { service.perform }

      it 'perform a booking calulation' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(270.82)
        end
      end

      it 'creates the Quotation correctly' do
        aggregate_failures do
          expect(Quotations::Quotation.count).to be(1)
          expect(quotation.pickup_address_id).to eq(service.shipment.pickup_address.id)
          expect(quotation.delivery_address_id).to eq(service.shipment.delivery_address.id)
        end
      end
    end
  end
end
