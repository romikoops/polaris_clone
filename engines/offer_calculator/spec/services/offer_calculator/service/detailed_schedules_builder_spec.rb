# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::DetailedSchedulesBuilder do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:cargo_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40_hq', load_type: 'container')
  end
  let(:vehicle) do
    FactoryBot.create(:legacy_vehicle,
                      transport_categories: [
                        fcl_20_transport_category,
                        fcl_40_transport_category,
                        fcl_40_hq_transport_category,
                        cargo_transport_category
                      ],
                      tenant_vehicles: [tenant_vehicle_1, tenant_vehicle_2])
  end
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express') }
  let(:trip_1) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary_1, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_1)
  end
  let(:trip_2) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary_2, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_2)
  end

  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:cargo_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: load_type,
                      direction: direction,
                      user: user,
                      tenant: tenant,
                      cargo_items: [cargo_item])
  end
  let(:agg_cargo_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: load_type,
                      direction: direction,
                      user: user,
                      tenant: tenant,
                      aggregated_cargo: FactoryBot.build(:legacy_aggregated_cargo))
  end
  let(:container_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'container',
                      direction: direction,
                      user: user,
                      tenant: tenant,
                      containers: containers)
  end

  let(:origin_nexus_1) { FactoryBot.create(:legacy_nexus, hubs: [origin_hub_1]) }
  let(:origin_nexus_2) { FactoryBot.create(:legacy_nexus, hubs: [origin_hub_2]) }
  let(:destination_nexus_1) { FactoryBot.create(:legacy_nexus, hubs: [destination_hub_1]) }
  let(:destination_nexus_2) { FactoryBot.create(:legacy_nexus, hubs: [destination_hub_2]) }
  let(:origin_hub_1) { FactoryBot.create(:legacy_hub, tenant: tenant, name: 'Hub 1') }
  let(:origin_hub_2) { FactoryBot.create(:legacy_hub, tenant: tenant, name: 'Hub 2') }
  let(:destination_hub_2) { FactoryBot.create(:legacy_hub, tenant: tenant, name: 'Hub 2') }
  let(:destination_hub_1) { FactoryBot.create(:legacy_hub, tenant: tenant, name: 'Hub 1') }
  let(:origin_stop_1) { FactoryBot.create(:legacy_stop, index: 0, hub: origin_hub_1, layovers: [origin_layover_1]) }
  let(:origin_stop_2) { FactoryBot.create(:legacy_stop, index: 0, hub: origin_hub_2, layovers: [origin_layover_2]) }
  let(:destination_stop_1) do
    FactoryBot.create(:legacy_stop, index: 1, hub: destination_hub_1, layovers: [destination_layover_1])
  end
  let(:destination_stop_2) do
    FactoryBot.create(:legacy_stop, index: 1, hub: destination_hub_2, layovers: [destination_layover_2])
  end
  let(:origin_layover_1) { FactoryBot.create(:legacy_layover, stop_index: 0) }
  let(:origin_layover_2) { FactoryBot.create(:legacy_layover, stop_index: 0) }
  let(:destination_layover_1) { FactoryBot.create(:legacy_layover, stop_index: 1) }
  let(:destination_layover_2) { FactoryBot.create(:legacy_layover, stop_index: 1) }
  let(:itinerary_1) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, tenant: tenant) }
  let(:itinerary_2) { FactoryBot.create(:legacy_itinerary, :shanghai_gothenburg, tenant: tenant) }
  let(:cargo_item) { FactoryBot.create(:legacy_cargo_item) }
  let(:schedules) do
    [
      OfferCalculator::Schedule.from_trip(trip_1),
      OfferCalculator::Schedule.from_trip(trip_2)
    ]
  end
  let(:containers) do
    [
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_20'),
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_40'),
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_40_hq')
    ]
  end

  let!(:default_margins) do
    %w(ocean air rail truck trucking local_charge).flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end

  before(:each) do
    stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'data.fixer.io',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json, headers: {})
  end

  describe '.grouped_schedules', :vcr do
    it 'returns two pricing objects with unique pricing_ids' do
      FactoryBot.create(:legacy_pricing,
                        itinerary: itinerary_1,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle_1,
                        transport_category: cargo_transport_category)
      FactoryBot.create(:legacy_pricing,
                        itinerary: itinerary_2,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle_2,
                        transport_category: cargo_transport_category)
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
      results = service.grouped_schedules(schedules: schedules,
                                          shipment: cargo_shipment,
                                          user: user)

      expect(results.length).to eq(2)
      expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
      expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
    end

    it 'returns two pricing objects with unique pricing_ids for quote shop' do
      FactoryBot.create(:legacy_pricing,
                        itinerary: itinerary_1,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle_1,
                        transport_category: cargo_transport_category)
      FactoryBot.create(:legacy_pricing,
                        itinerary: itinerary_2,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle_2,
                        transport_category: cargo_transport_category)
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
      allow(service).to receive(:quotation_tool?).and_return(true)

      results = service.grouped_schedules(schedules: schedules,
                                          shipment: cargo_shipment,
                                          user: user)

      expect(results.length).to eq(2)
      expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
      expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
    end

    it 'returns three pricing objects with unique pricing_ids and cargo classes by closing_date (fcl)' do
      pricing_1 = FactoryBot.create(:legacy_fcl_20_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1)
      pricing_2 = FactoryBot.create(:legacy_fcl_40_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1)
      pricing_3 = FactoryBot.create(:legacy_fcl_40_hq_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1)
      closing_date_schedules = [
        FactoryBot.create(:legacy_trip,
                          tenant_vehicle: pricing_1.tenant_vehicle,
                          itinerary: pricing_1.itinerary,
                          closing_date: pricing_1.expiration_date - 2.days,
                          start_date: pricing_1.expiration_date + 2.days,
                          end_date: pricing_1.expiration_date + 22.days),
        FactoryBot.create(:legacy_trip,
                          tenant_vehicle: pricing_2.tenant_vehicle,
                          itinerary: pricing_2.itinerary,
                          closing_date: pricing_2.expiration_date - 2.days,
                          start_date: pricing_2.expiration_date + 2.days,
                          end_date: pricing_2.expiration_date + 22.days)
      ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }

      service = described_class.new(shipment: container_shipment, sandbox: nil)
      results = service.grouped_schedules(schedules: closing_date_schedules,
                                          shipment: container_shipment,
                                          user: user)
      expect(results.length).to eq(1)
      expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_20').nil? }).to eq(false)
      expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40').nil? }).to eq(false)
      expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40_hq').nil? }).to eq(false)
    end

    it 'returns two pricing objects with unique pricing_ids by closing_date' do
      pricing_1 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1,
                                    transport_category: cargo_transport_category)
      pricing_2 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_2,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_2,
                                    transport_category: cargo_transport_category)
      closing_date_schedules = [
        FactoryBot.create(:legacy_trip,
                          tenant_vehicle: pricing_1.tenant_vehicle,
                          itinerary: pricing_1.itinerary,
                          closing_date: pricing_1.expiration_date - 2.days,
                          start_date: pricing_1.expiration_date + 2.days,
                          end_date: pricing_1.expiration_date + 22.days),
        FactoryBot.create(:legacy_trip,
                          tenant_vehicle: pricing_2.tenant_vehicle,
                          itinerary: pricing_2.itinerary,
                          closing_date: pricing_2.expiration_date - 2.days,
                          start_date: pricing_2.expiration_date + 2.days,
                          end_date: pricing_2.expiration_date + 22.days)
      ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
      results = service.grouped_schedules(schedules: closing_date_schedules,
                                          shipment: cargo_shipment,
                                          user: user)

      expect(results.length).to eq(2)
      expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
      expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
    end
    context 'base_pricing' do
      let!(:scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true }) }

      it 'returns two pricing objects with unique pricing_ids (base_pricing) on quote shop' do
        pricing_1 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_2 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_2,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_2)
        closing_date_schedules = [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_1.tenant_vehicle,
                            itinerary: pricing_1.itinerary),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_2.tenant_vehicle,
                            itinerary: pricing_2.itinerary)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
        service = described_class.new(shipment: cargo_shipment, sandbox: nil)

        allow(service).to receive(:quotation_tool?).and_return(true)

        results = service.grouped_schedules(schedules: closing_date_schedules,
                                            shipment: cargo_shipment,
                                            user: user)

        expect(results.length).to eq(2)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
        expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
      end

      it 'returns two pricing objects with unique pricing_ids (base_pricing)' do
        pricing_1 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_2 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_2,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_2)
        closing_date_schedules = [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_1.tenant_vehicle,
                            itinerary: pricing_1.itinerary),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_2.tenant_vehicle,
                            itinerary: pricing_2.itinerary)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
        service = described_class.new(shipment: cargo_shipment, sandbox: nil)
        results = service.grouped_schedules(schedules: closing_date_schedules,
                                            shipment: cargo_shipment,
                                            user: user)

        expect(results.length).to eq(2)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
        expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
      end

      it 'returns two pricing objects with unique pricing_ids by closing_date (base_pricing)' do
        pricing_1 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_2 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_2,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_2)
        closing_date_schedules = [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_1.tenant_vehicle,
                            itinerary: pricing_1.itinerary,
                            closing_date: pricing_1.expiration_date - 2.days,
                            start_date: pricing_1.expiration_date + 2.days,
                            end_date: pricing_1.expiration_date + 22.days),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_2.tenant_vehicle,
                            itinerary: pricing_2.itinerary,
                            closing_date: pricing_2.expiration_date - 2.days,
                            start_date: pricing_2.expiration_date + 2.days,
                            end_date: pricing_2.expiration_date + 22.days)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
        service = described_class.new(shipment: cargo_shipment, sandbox: nil)
        results = service.grouped_schedules(schedules: closing_date_schedules,
                                            shipment: cargo_shipment,
                                            user: user)

        expect(results.length).to eq(2)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
        expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
      end

      it 'returns three pricing objects with unique pricing_ids and cargo classes by closing_date (base_pricing)' do
        pricing_1 = FactoryBot.create(:fcl_20_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_2 = FactoryBot.create(:fcl_40_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_3 = FactoryBot.create(:fcl_40_hq_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        closing_date_schedules = [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_1.tenant_vehicle,
                            itinerary: pricing_1.itinerary,
                            load_type: 'container')
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
        service = described_class.new(shipment: container_shipment, sandbox: nil)
        results = service.grouped_schedules(schedules: closing_date_schedules,
                                            shipment: container_shipment,
                                            user: user)
        expect(results.length).to eq(1)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_20').nil? }).to eq(false)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40').nil? }).to eq(false)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40_hq').nil? }).to eq(false)
      end

      it 'returns three pricing objects with unique pricing_ids and cargo classes by closing_date (base_pricing)' do
        pricing_1 = FactoryBot.create(:fcl_20_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_2 = FactoryBot.create(:fcl_40_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        pricing_3 = FactoryBot.create(:fcl_40_hq_pricing,
                                      itinerary: itinerary_1,
                                      tenant: tenant,
                                      tenant_vehicle: tenant_vehicle_1)
        closing_date_schedules = [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_1.tenant_vehicle,
                            itinerary: pricing_1.itinerary,
                            closing_date: pricing_1.expiration_date - 2.days,
                            start_date: pricing_1.expiration_date + 2.days,
                            end_date: pricing_1.expiration_date + 22.days),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing_2.tenant_vehicle,
                            itinerary: pricing_2.itinerary,
                            closing_date: pricing_2.expiration_date - 2.days,
                            start_date: pricing_2.expiration_date + 2.days,
                            end_date: pricing_2.expiration_date + 22.days)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }

        margin = FactoryBot.create(:freight_margin,
                                   itinerary_id: itinerary_1.id,
                                   applicable: tenants_user,
                                   tenant: tenants_tenant,
                                   effective_date: pricing_1.effective_date - 10.days,
                                   expiration_date: pricing_1.effective_date + 5.days)
        service = described_class.new(shipment: container_shipment, sandbox: nil)
        results = service.grouped_schedules(schedules: closing_date_schedules,
                                            shipment: container_shipment,
                                            user: user)
        expect(results.length).to eq(2)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_20').nil? }).to eq(false)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40').nil? }).to eq(false)
        expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40_hq').nil? }).to eq(false)
      end
    end
  end

  describe '.sort_pricings', :vcr do
    it 'returns an object containing pricings grouped by transport category (lcl)' do
      pricing_1 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1,
                                    transport_category: cargo_transport_category)
      FactoryBot.create(:legacy_pricing,
                        itinerary: itinerary_2,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle_2,
                        transport_category: cargo_transport_category)
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
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
      expect(results.values.first.first['id']).to eq(pricing_1.id)
    end

    it 'returns an object containing pricings grouped by transport category (fcl)' do
      pricing_1 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1,
                                    transport_category: fcl_20_transport_category)
      pricing_2 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1,
                                    transport_category: fcl_40_transport_category)
      pricing_3 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1,
                                    transport_category: fcl_40_hq_transport_category)
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      results = service.sort_pricings(
        schedules: schedules,
        user_pricing_id: nil,
        cargo_classes: Legacy::Container::CARGO_CLASSES,
        dates: dates,
        dedicated_pricings_only: false
      )

      expect(results.keys.length).to eq(3)
      expect(results[fcl_40_hq_transport_category.id].first['id']).to eq(pricing_3.id)
      expect(results[fcl_40_transport_category.id].first['id']).to eq(pricing_2.id)
      expect(results[fcl_20_transport_category.id].first['id']).to eq(pricing_1.id)
    end

    it 'returns pricings valid for closing_dates if departure dates return nil' do
      pricing_1 = FactoryBot.create(:legacy_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1,
                                    transport_category: cargo_transport_category,
                                    effective_date: Date.parse('01/01/2019'),
                                    expiration_date: Date.parse('31/01/2019'))
      trip = FactoryBot.create(:legacy_trip,
                               start_date: Date.parse('02/02/2019'),
                               end_date: Date.parse('28/02/2019'),
                               closing_date: Date.parse('28/01/2019'),
                               tenant_vehicle: tenant_vehicle_1,
                               itinerary: itinerary_1)
      schedules = [OfferCalculator::Schedule.from_trip(trip)]
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
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
      expect(results.values.first.first['id']).to eq(pricing_1.id)
    end

    it 'returns pricings valid for closing_dates and user if dedicated pricing available' do
      FactoryBot.create(:legacy_pricing,
                        itinerary: itinerary_1,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle_1,
                        transport_category: cargo_transport_category,
                        effective_date: Date.parse('01/01/2019'),
                        expiration_date: Date.parse('31/01/2019'))
      pricing_target = FactoryBot.create(:legacy_pricing,
                                         user: user,
                                         itinerary: itinerary_1,
                                         tenant: tenant,
                                         tenant_vehicle: tenant_vehicle_1,
                                         transport_category: cargo_transport_category,
                                         effective_date: Date.parse('01/01/2019'),
                                         expiration_date: Date.parse('31/01/2019'))
      trip = FactoryBot.create(:legacy_trip,
                               start_date: Date.parse('02/02/2019'),
                               end_date: Date.parse('28/02/2019'),
                               closing_date: Date.parse('28/01/2019'),
                               tenant_vehicle: tenant_vehicle_1,
                               itinerary: itinerary_1)
      schedules = [OfferCalculator::Schedule.from_trip(trip)]
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
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
      expect(results.values.first.first['id']).to eq(pricing_target.id)
    end
  end

  describe '.sort_schedule_permutations', :vcr do
    it 'returns an object containing schedules grouped by pricing permutation' do
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)

      results = service.sort_schedule_permutations(schedules: schedules)
      expect(results.keys.length).to eq(2)
      expect(results.values.map(&:length).uniq).to eq([1])
    end
  end

  describe '.perform', :vcr do
    let(:no_trucking_data) { { trucking_pricings: {}, metadata: [] } }
    context 'legacy' do
      let!(:pricing_one) do
        FactoryBot.create(:legacy_lcl_pricing,
                          itinerary: itinerary_1,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: cargo_transport_category)
      end
      let!(:pricing_fcl_20) do
        FactoryBot.create(:legacy_fcl_20_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: fcl_20_transport_category)
      end
      let!(:pricing_fcl_40) do
        FactoryBot.create(:legacy_fcl_40_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: fcl_40_transport_category)
      end
      let!(:pricing_fcl_40_hq) do
        FactoryBot.create(:legacy_fcl_40_hq_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: fcl_40_hq_transport_category)
      end

      it 'returns an object with two quotes with subtotals and grand totals' do
        service = described_class.new(shipment: cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end

      it 'returns an object with two quotes with subtotals and grand totals w/ aggregated cargo' do
        service = described_class.new(shipment: agg_cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end

      it 'returns an object with two quotes with subtotals and grand totals w/ containers' do
        service = described_class.new(shipment: container_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end
    end

    context 'base pricing' do
      let!(:pricing_one) do
        FactoryBot.create(:lcl_pricing,
                          itinerary: itinerary_1,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenant)
      end
      let!(:pricing_fcl_20) do
        FactoryBot.create(:fcl_20_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1)
      end
      let!(:pricing_fcl_40) do
        FactoryBot.create(:fcl_40_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1)
      end
      let!(:pricing_fcl_40_hq) do
        FactoryBot.create(:fcl_40_hq_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1)
      end

      let!(:scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true }) }
      it 'returns an object with two quotes with subtotals and grand totals' do
        service = described_class.new(shipment: cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end

      it 'returns an object with two quotes with subtotals and grand totals w/ flat margins' do
        FactoryBot.create(:pricings_margin,
                                   operator: '+',
                                   value: 100,
                                   itinerary_id: itinerary_1.id,
                                   applicable: tenants_user,
                                   tenant: tenants_tenant)
        service = described_class.new(shipment: cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end

      it 'returns an object with two quotes with subtotals and grand totals w/ aggregated cargo' do
        service = described_class.new(shipment: agg_cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end

      it 'returns an object with two quotes with subtotals and grand totals w/ containers' do
        service = described_class.new(shipment: agg_cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end
    end
  end
end
