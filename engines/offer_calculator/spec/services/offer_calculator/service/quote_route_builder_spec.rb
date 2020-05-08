# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::QuoteRouteBuilder do
  before do
    FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: false })
  end

  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      user: user,
                      desired_start_date: Time.zone.tomorrow,
                      tenant: tenant)
  end
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, tenant: tenant) }
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
        tenant_vehicle_id: tenant_vehicle.id
      )
    ]
  end
  let(:results) { described_class.new(shipment: shipment).perform(routes, hubs) }

  describe '.perform', :vcr do
    context 'without trucking' do
      it 'return the route detail hashes' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(OfferCalculator::Schedule.quote_trip_start_date)
          expect(results.first.eta).to eq(OfferCalculator::Schedule.quote_trip_end_date)
        end
      end
    end

    context 'with transit_time' do
      before do
        FactoryBot.create(:legacy_transit_time, itinerary: itinerary, tenant_vehicle_id: tenant_vehicle.id, duration: 35)
      end

      let(:desired_end_date) { OfferCalculator::Schedule.quote_trip_start_date + 35.days }

      it 'return the route detail hashes' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(OfferCalculator::Schedule.quote_trip_start_date)
          expect(results.first.eta).to eq(desired_end_date)
        end
      end
    end

    context  'with trucking' do
      before do
        google_directions = instance_double('OfferCalculator::GoogleDirections', driving_time_in_seconds: 10_000, driving_time_in_seconds_for_trucks: 14_000)
        allow(OfferCalculator::GoogleDirections).to receive(:new).and_return(google_directions)
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(shipment).to receive(:pickup_address).and_return(pickup_address)
      end

      let(:pickup_address) { FactoryBot.create(:gothenburg_address) }

      it 'return the route detail hashes' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(OfferCalculator::Schedule.quote_trip_start_date)
          expect(results.first.eta).to eq(OfferCalculator::Schedule.quote_trip_end_date)
        end
      end
    end
  end
end
