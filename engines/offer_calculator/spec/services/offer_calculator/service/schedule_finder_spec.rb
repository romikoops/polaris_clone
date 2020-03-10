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
  let(:klass) { described_class.new(shipment: shipment) }
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: origin_hub.id),
      destination: Legacy::Hub.where(id: destination_hub.id)
    }
  end
  let(:results) { klass.perform(routes, 5, hubs) }

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do
    before do
      FactoryBot.create(:trip_with_layovers, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    end

    context 'with success' do
      before do
        allow(klass).to receive(:current_etd_in_search).and_return(shipment.desired_start_date + 1000.seconds)
      end

      let(:routes) do
        [
          OfferCalculator::Route.new(
            itinerary_id: itinerary.id,
            origin_stop_id: itinerary.stops.first.id,
            destination_stop_id: itinerary.stops.last.id,
            tenant_vehicle_id: tenant_vehicle.id,
            mode_of_transport: 'ocean'
          )
        ]
      end

      describe '.perform', :vcr do
        it 'return the valid schedules' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end

        it 'return the valid schedules with pre_carriage' do
          shipment.update(has_pre_carriage: true)
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end

        it 'return the valid schedules with default delay' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end
      end

      context 'with failures' do
        before do
          allow(klass).to receive(:current_etd_in_search).and_raise(OfferCalculator::Calculator::NoDirectionsFound)
        end

        it 'return raises an error when no driving time is found' do
          expect { klass.perform(routes, nil, hubs) }.to raise_error(OfferCalculator::Calculator::NoDirectionsFound)
        end
      end
    end
  end
end
