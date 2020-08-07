# frozen_string_literal: true

require 'rails_helper'
require_relative "../../../shared_contexts/basic_setup.rb"

RSpec.describe OfferCalculator::Service::QuoteRouteBuilder do
  include_context "offer_calculator_shared_context"

  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      user: user,
                      desired_start_date: Time.zone.tomorrow,
                      organization: organization)
  end
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
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
  let(:results) { described_class.new(shipment: shipment, quotation: quotation).perform(routes, hubs) }

  before do
    ::Organizations.current_id = organization.id
  end

  describe '.perform' do
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

    context 'with custom buffer' do
      before do
        FactoryBot.create(:organizations_scope, target: organization, content: { search_buffer: 0})
      end

      let(:desired_start_date) { Time.zone.now.beginning_of_day }

      it 'return the route detail hashes' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(desired_start_date)
          expect(results.first.closing_date).to eq(desired_start_date)
          expect(results.first.eta).to eq(OfferCalculator::Schedule.quote_trip_end_date)
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
