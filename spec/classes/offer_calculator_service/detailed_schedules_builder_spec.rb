# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculatorService::DetailedSchedulesBuilder do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { create(:tenant) }
  let(:transport_category) { create(:transport_category, cargo_class: 'lcl', load_type: 'cargo_item') }
  let(:vehicle) { create(:vehicle, transport_categories: [transport_category], tenant_vehicles: [tenant_vehicle_1, tenant_vehicle_2]) }
  let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'express') }
  let(:trip_1) { create(:trip, itinerary: itinerary_1, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_1) }
  let(:trip_2) { create(:trip, itinerary: itinerary_2, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_2) }

  let(:user) { create(:user, tenant: tenant) }
  let(:shipment) { create(:shipment, load_type: load_type, direction: direction, user: user, tenant: tenant, cargo_items: [cargo_item]) }

  let(:origin_nexus_1) { create(:nexus, hubs: [origin_hub_1]) }
  let(:origin_nexus_2) { create(:nexus, hubs: [origin_hub_2]) }
  let(:destination_nexus_1) { create(:nexus, hubs: [destination_hub_1]) }
  let(:destination_nexus_2) { create(:nexus, hubs: [destination_hub_2]) }
  let(:origin_hub_1) { create(:hub, tenant: tenant, name: 'Hub 1') }
  let(:origin_hub_2) { create(:hub, tenant: tenant, name: 'Hub 2') }
  let(:destination_hub_2) { create(:hub, tenant: tenant, name: 'Hub 2') }
  let(:destination_hub_1) { create(:hub, tenant: tenant, name: 'Hub 1') }
  let(:origin_stop_1) { create(:stop, index: 0, hub: origin_hub_1, layovers: [origin_layover_1]) }
  let(:origin_stop_2) { create(:stop, index: 0, hub: origin_hub_2, layovers: [origin_layover_2]) }
  let(:destination_stop_1) { create(:stop, index: 1, hub: destination_hub_1, layovers: [destination_layover_1]) }
  let(:destination_stop_2) { create(:stop, index: 1, hub: destination_hub_2, layovers: [destination_layover_2]) }
  let(:origin_layover_1) { create(:layover, stop_index: 0) }
  let(:origin_layover_2) { create(:layover, stop_index: 0) }
  let(:destination_layover_1) { create(:layover, stop_index: 1) }
  let(:destination_layover_2) { create(:layover, stop_index: 1) }
  let(:itinerary_1) { create(:itinerary, tenant: tenant) }
  let(:itinerary_2) { create(:itinerary, tenant: tenant) }
  let(:cargo_item) { create(:cargo_item) }
  let(:schedules) do
    [
      Schedule.from_trip(trip_1),
      Schedule.from_trip(trip_2)
    ]
  end

  describe '.grouped_schedules', :vcr do
    it 'returns two pricing objects with unique pricing_ids' do
      create(:pricing,
             itinerary: itinerary_1,
             tenant_vehicle: tenant_vehicle_1,
             transport_category: transport_category)
      create(:pricing,
             itinerary: itinerary_2,
             tenant_vehicle: tenant_vehicle_2,
             transport_category: transport_category)
      service = described_class.new(shipment)
      results = service.grouped_schedules(schedules: schedules, shipment: shipment, user: user)
      expect(results.length).to eq(2)
      expect(results.any? { |r| r.dig(:pricing_ids, 'lcl').nil? }).to eq(false)
      expect(results.map { |r| r.dig(:pricing_ids, 'lcl') }.uniq.length).to eq(2)
    end
  end

  describe '.sort_pricings', :vcr do
    it 'returns an object containing pricings grouped by trans category' do
      pricing_1 = create(:pricing,
                         itinerary: itinerary_1,
                         tenant_vehicle: tenant_vehicle_1,
                         transport_category: transport_category)
      create(:pricing,
             itinerary: itinerary_2,
             tenant_vehicle: tenant_vehicle_2,
             transport_category: transport_category)
      service = described_class.new(shipment)

      results = service.sort_pricings(
        schedules: schedules,
        user_pricing_id: nil,
        cargo_classes: ['lcl'],
        start_date: schedules.first.eta,
        end_date: schedules.first.etd
      )
      expect(results.keys.length).to eq(1)
      expect(results.values.first.first).to eq(pricing_1)
    end
  end

  describe '.sort_schedule_permutations', :vcr do
    it 'returns an object containing schedules grouped by pricing permutation' do
      service = described_class.new(shipment)

      results = service.sort_schedule_permutations(schedules: schedules)
      expect(results.keys.length).to eq(2)
      expect(results.values.map(&:length).uniq).to eq([1])
    end
  end
end
