# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::ScheduleFinder do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, tenant: tenant) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      tenant: tenant,
                      user: user,
                      trip: nil,
                      origin_hub: nil,
                      destination_hub: nil,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      destination_nexus_id: destination_hub.nexus_id,
                      desired_start_date: Date.today + 4.days,
                      cargo_items: [FactoryBot.create(:legacy_cargo_item)],
                      itinerary: itinerary,
                      has_pre_carriage: true)
  end
  let!(:trip) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
  let!(:pricings) do
    [
      FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle),
      FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle),
      FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle),
      FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    ]
  end

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do

    before(:each) do
      stub_request(:get, 'https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=1576800000&destination=57.694253,11.854048&key=&language=en&mode=driving&origin=57.694253,11.854048&traffic_model=pessimistic')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: FactoryBot.create(:google_directions_response), headers: {})
    end
    
    before(:each) do
      directions_service = double('OfferCalculator::GoogleDirections')
      allow_any_instance_of(OfferCalculator::GoogleDirections).to receive(:initialize).and_return(directions_service)
      allow_any_instance_of(OfferCalculator::GoogleDirections).to receive(:driving_time_in_seconds).and_return(1000)
    end
    
    context 'class methods' do
      let(:routes) do
        [
          OfferCalculator::Route.new(
            itinerary_id: itinerary.id,
            origin_stop_id: itinerary.stops.first.id,
            destination_stop_id: itinerary.stops.last.id,
            mode_of_transport: 'ocean'
          )
        ]
      end
      describe '.perform', :vcr do
        it 'return the valid schedules' do
          hubs = {
            origin: Legacy::Hub.where(id: origin_hub.id),
            destination: Legacy::Hub.where(id: destination_hub.id)
          }
          results = described_class.new(shipment: shipment).perform(routes, 5, hubs)

          expect(results.length).to eq(1)
          expect(results.first.origin_hub).to eq(origin_hub)
          expect(results.first.destination_hub).to eq(destination_hub)
        end

        it 'return the valid schedules with pre_carriage' do
          hubs = {
            origin: Legacy::Hub.where(id: origin_hub.id),
            destination: Legacy::Hub.where(id: destination_hub.id)
          }
          shipment.update(has_pre_carriage: true)
          results = described_class.new(shipment: shipment).perform(routes, 5, hubs)

          expect(results.length).to eq(1)
          expect(results.first.origin_hub).to eq(origin_hub)
          expect(results.first.destination_hub).to eq(destination_hub)
        end

        it 'return the valid schedules with default delay' do
          hubs = {
            origin: Legacy::Hub.where(id: origin_hub.id),
            destination: Legacy::Hub.where(id: destination_hub.id)
          }
          results = described_class.new(shipment: shipment).perform(routes, nil, hubs)

          expect(results.length).to eq(1)
          expect(results.first.origin_hub).to eq(origin_hub)
          expect(results.first.destination_hub).to eq(destination_hub)
        end

        it 'return raises an error when no driving time is found' do
          hubs = {
            origin: Legacy::Hub.where(id: origin_hub.id),
            destination: Legacy::Hub.where(id: destination_hub.id)
          }
          allow_any_instance_of(OfferCalculator::GoogleDirections).to receive(:driving_time_in_seconds).and_raise(OfferCalculator::Calculator::NoDrivingTime)

          expect { described_class.new(shipment: shipment).perform(routes, nil, hubs) }.to raise_error(OfferCalculator::Calculator::NoDirectionsFound)
        end
      end
    end
  end
end
