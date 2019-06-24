# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculatorService::DetailedSchedulesBuilder do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { create(:tenant) }
  let(:cargo_transport_category) do
    create(:transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    create(:transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    create(:transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    create(:transport_category, cargo_class: 'fcl_40_hq', load_type: 'container')
  end
  let(:vehicle) do
    create(:vehicle,
           transport_categories: [
             fcl_20_transport_category,
             fcl_40_transport_category,
             fcl_40_hq_transport_category,
             cargo_transport_category
           ],
           tenant_vehicles: [tenant_vehicle_1, tenant_vehicle_2])
  end
  let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'express') }
  let(:trip_1) do
    create(:trip, itinerary: itinerary_1, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_1)
  end
  let(:trip_2) do
    create(:trip, itinerary: itinerary_2, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_2)
  end

  let(:user) { create(:user, tenant: tenant, tokens: {}) }
  let(:cargo_shipment) do
    create(:shipment,
           load_type: load_type,
           direction: direction,
           user: user,
           tenant: tenant,
           cargo_items: [cargo_item])
  end
  let(:container_shipment) do
    create(:shipment,
           load_type: load_type,
           direction: direction,
           user: user,
           tenant: tenant,
           cargo_items: containers)
  end

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
  let(:destination_stop_1) do
    create(:stop, index: 1, hub: destination_hub_1, layovers: [destination_layover_1])
  end
  let(:destination_stop_2) do
    create(:stop, index: 1, hub: destination_hub_2, layovers: [destination_layover_2])
  end
  let(:origin_layover_1) { create(:layover, stop_index: 0) }
  let(:origin_layover_2) { create(:layover, stop_index: 0) }
  let(:destination_layover_1) { create(:layover, stop_index: 1) }
  let(:destination_layover_2) { create(:layover, stop_index: 1) }
  let(:itinerary_1) { create(:itinerary, tenant: tenant) }
  let(:itinerary_2) { create(:itinerary, tenant: tenant) }
  let(:cargo_item) { create(:cargo_item) }
  let(:schedules) do
    [
      Legacy::Schedule.from_trip(trip_1),
      Legacy::Schedule.from_trip(trip_2)
    ]
  end
  let(:containers) do
    [
      create(:container, cargo_class: 'fcl_20'),
      create(:container, cargo_class: 'fcl_40'),
      create(:container, cargo_class: 'fcl_40_hq')
    ]
  end

  describe '.grouped_schedules', :vcr do
    it 'returns two pricing objects with unique pricing_ids' do
      create(:pricing,
             itinerary: itinerary_1,
             tenant_vehicle: tenant_vehicle_1,
             transport_category: cargo_transport_category)
      create(:pricing,
             itinerary: itinerary_2,
             tenant_vehicle: tenant_vehicle_2,
             transport_category: cargo_transport_category)
      service = described_class.new(cargo_shipment)
      results = service.grouped_schedules(schedules: schedules,
                                          shipment: cargo_shipment,
                                          user: user)

      expect(results.length).to eq(2)
      expect(results.any? { |r| r.dig(:pricing_ids, 'lcl').nil? }).to eq(false)
      expect(results.map { |r| r.dig(:pricing_ids, 'lcl') }.uniq.length).to eq(2)
    end
  end

  describe '.sort_pricings', :vcr do
    it 'returns an object containing pricings grouped by transport category (lcl)' do
      pricing_1 = create(:pricing,
                         itinerary: itinerary_1,
                         tenant_vehicle: tenant_vehicle_1,
                         transport_category: cargo_transport_category)
      create(:pricing,
             itinerary: itinerary_2,
             tenant_vehicle: tenant_vehicle_2,
             transport_category: cargo_transport_category)
      service = described_class.new(cargo_shipment)
      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      results = service.sort_pricings(
        schedules: schedules,
        user_pricing_id: nil,
        cargo_classes: ['lcl'],
        dates: dates,
        dedicated_pricings_only: false
      )
      expect(results.keys.length).to eq(1)
      expect(results.values.first.first).to eq(pricing_1)
    end
    it 'returns an object containing pricings grouped by transport category (fcl)' do
      pricing_1 = create(:pricing,
                         itinerary: itinerary_1,
                         tenant_vehicle: tenant_vehicle_1,
                         transport_category: fcl_20_transport_category)
      pricing_2 = create(:pricing,
                         itinerary: itinerary_1,
                         tenant_vehicle: tenant_vehicle_1,
                         transport_category: fcl_40_transport_category)
      pricing_3 = create(:pricing,
                         itinerary: itinerary_1,
                         tenant_vehicle: tenant_vehicle_1,
                         transport_category: fcl_40_hq_transport_category)
      service = described_class.new(cargo_shipment)
      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      results = service.sort_pricings(
        schedules: schedules,
        user_pricing_id: nil,
        cargo_classes: Container::CARGO_CLASSES,
        dates: dates,
        dedicated_pricings_only: false
      )

      expect(results.keys.length).to eq(3)
      expect(results[fcl_40_hq_transport_category.id.to_s].first).to eq(pricing_3)
      expect(results[fcl_40_transport_category.id.to_s].first).to eq(pricing_2)
      expect(results[fcl_20_transport_category.id.to_s].first).to eq(pricing_1)
    end

    it 'returns pricings valid for closing_dates if departure dates return nil' do
      pricing_1 = create(:pricing,
                         itinerary: itinerary_1,
                         tenant_vehicle: tenant_vehicle_1,
                         transport_category: cargo_transport_category,
                         effective_date: Date.parse('01/01/2019'),
                         expiration_date: Date.parse('31/01/2019'))
      trip = create(:trip,
                    start_date: Date.parse('02/02/2019'),
                    end_date: Date.parse('28/02/2019'),
                    closing_date: Date.parse('28/01/2019'),
                    tenant_vehicle: tenant_vehicle_1,
                    itinerary: itinerary_1)
      schedules = [Legacy::Schedule.from_trip(trip)]
      service = described_class.new(cargo_shipment)
      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      results = service.sort_pricings(
        schedules: schedules,
        user_pricing_id: nil,
        cargo_classes: ['lcl'],
        dates: dates,
        dedicated_pricings_only: false
      )
      expect(results.keys.length).to eq(1)
      expect(results.values.first.first).to eq(pricing_1)
    end

    it 'returns pricings valid for closing_dates and user if dedicated pricing available' do
      create(:pricing,
             itinerary: itinerary_1,
             tenant_vehicle: tenant_vehicle_1,
             transport_category: cargo_transport_category,
             effective_date: Date.parse('01/01/2019'),
             expiration_date: Date.parse('31/01/2019'))
      pricing_target = create(:pricing,
                              user: user,
                              itinerary: itinerary_1,
                              tenant_vehicle: tenant_vehicle_1,
                              transport_category: cargo_transport_category,
                              effective_date: Date.parse('01/01/2019'),
                              expiration_date: Date.parse('31/01/2019'))
      trip = create(:trip,
                    start_date: Date.parse('02/02/2019'),
                    end_date: Date.parse('28/02/2019'),
                    closing_date: Date.parse('28/01/2019'),
                    tenant_vehicle: tenant_vehicle_1,
                    itinerary: itinerary_1)
      schedules = [Legacy::Schedule.from_trip(trip)]
      service = described_class.new(cargo_shipment)
      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      results = service.sort_pricings(
        schedules: schedules,
        user_pricing_id: user.id,
        cargo_classes: ['lcl'],
        dates: dates,
        dedicated_pricings_only: true
      )
      expect(results.keys.length).to eq(1)
      expect(results.values.first.first).to eq(pricing_target)
    end
  end

  describe '.sort_schedule_permutations', :vcr do
    it 'returns an object containing schedules grouped by pricing permutation' do
      service = described_class.new(cargo_shipment)

      results = service.sort_schedule_permutations(schedules: schedules)
      expect(results.keys.length).to eq(2)
      expect(results.values.map(&:length).uniq).to eq([1])
    end
  end
end
