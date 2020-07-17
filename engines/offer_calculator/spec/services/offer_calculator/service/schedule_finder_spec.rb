# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::ScheduleFinder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      organization: organization,
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
  let(:klass) { described_class.new(shipment: shipment, quotation: quotation) }
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: origin_hub.id),
      destination: Legacy::Hub.where(id: destination_hub.id)
    }
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
  let(:departure_type) { 'departure' }
  let(:results) { klass.perform(routes, 5, hubs) }
  let!(:trip) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
  let(:start_date) { shipment.desired_start_date + 1000.seconds }

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do
    before do
      FactoryBot.create(:lcl_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle
      )
      FactoryBot.create(:fcl_20_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle
      )
      FactoryBot.create(:fcl_40_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle
      )
      FactoryBot.create(:fcl_40_hq_pricing,
        itinerary: itinerary,
        organization: organization,
        tenant_vehicle: tenant_vehicle
      )
      FactoryBot.create(:organizations_scope,
        target: organization,
        content: {departure_query_type: departure_type}
      )
    end

    describe '.perform' do
      context 'without trucking' do
        before do
          allow(shipment).to receive(:has_pre_carriage?).and_return(false)
        end

        it 'return the valid schedules' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end
      end

      context 'with trucking' do
        before do
          allow(shipment).to receive(:has_pre_carriage?).and_return(true)
          google_directions = instance_double('OfferCalculator::GoogleDirections')
          allow(OfferCalculator::GoogleDirections).to receive(:new).and_return(google_directions)
          allow(google_directions).to receive(:driving_time_in_seconds).and_return(10_000)
          allow(google_directions).to receive(:driving_time_in_seconds_for_trucks).and_return(14_000)
        end

        it 'return the valid schedules with pre_carriage' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.first.origin_hub).to eq(origin_hub)
            expect(results.first.destination_hub).to eq(destination_hub)
          end
        end
      end

      context 'with no driving time' do
        before do
          allow(shipment).to receive(:has_pre_carriage?).and_return(true)
          google_directions = instance_double('OfferCalculator::GoogleDirections')
          allow(OfferCalculator::GoogleDirections).to receive(:new).and_return(google_directions)
          allow(google_directions).to receive(:driving_time_in_seconds).and_raise(OfferCalculator::Errors::NoDrivingTime)
        end

        it 'return raises an error when no driving time is found' do
          expect { klass.perform(routes, nil, hubs) }.to raise_error(OfferCalculator::Errors::NoDirectionsFound)
        end
      end
    end
  end
end