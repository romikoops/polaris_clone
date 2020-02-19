# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::DetailedSchedulesBuilder do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:cargo_transport_category) do
    Legacy::TransportCategory.find_by(cargo_class: 'lcl', load_type: 'cargo_item') ||
      FactoryBot.create(:legacy_transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    Legacy::TransportCategory.find_by(cargo_class: 'fcl_20', load_type: 'container') ||
      FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    Legacy::TransportCategory.find_by(cargo_class: 'fcl_40', load_type: 'container') ||
      FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    Legacy::TransportCategory.find_by(cargo_class: 'fcl_40_hq', load_type: 'container') ||
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
                      tenant_vehicles: [tenant_vehicle, tenant_vehicle2])
  end
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express') }
  let(:trip_1) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle)
  end
  let(:trip_2) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary2, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle2)
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
  let(:origin_layover_1) { FactoryBot.create(:legacy_layover, stop_index: 0) }
  let(:origin_layover_2) { FactoryBot.create(:legacy_layover, stop_index: 0) }
  let(:destination_layover_1) { FactoryBot.create(:legacy_layover, stop_index: 1) }
  let(:destination_layover_2) { FactoryBot.create(:legacy_layover, stop_index: 1) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, tenant: tenant) }
  let(:itinerary2) { FactoryBot.create(:legacy_itinerary, :shanghai_gothenburg, tenant: tenant) }
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

  let(:group) do
    FactoryBot.create(:tenants_group, tenant: tenants_tenant).tap do |group|
      FactoryBot.create(:tenants_membership, member: tenants_user, group: group)
    end
  end
  let(:no_trucking_data) { { trucking_pricings: {}, metadata: [] } }
  let(:target_trucking_data) { no_trucking_data }
  let(:klass) { described_class.new(shipment: target_shipment, sandbox: nil) }
  let(:results) { klass.perform(schedules, target_trucking_data, user) }
  let(:target_shipment) { cargo_shipment }
  let(:lcl_pricing) do
    FactoryBot.create(:loaded_lcl_pricing,
                      itinerary: itinerary,
                      tenant_vehicle: tenant_vehicle,
                      tenant: tenant)
  end
  let(:fcl_20_pricing) do
    FactoryBot.create(:fcl_20_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle)
  end
  let(:fcl_40_pricing) do
    FactoryBot.create(:fcl_40_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle)
  end
  let(:fcl_40_hq_pricing) do
    FactoryBot.create(:fcl_40_hq_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle)
  end
  let(:legacy_lcl_pricing) do
    FactoryBot.create(:legacy_lcl_pricing,
                      itinerary: itinerary,
                      tenant_vehicle: tenant_vehicle,
                      tenant: tenant,
                      transport_category: cargo_transport_category)
  end
  let(:legacy_fcl_20_pricing) do
    FactoryBot.create(:legacy_fcl_20_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle,
                      transport_category: fcl_20_transport_category)
  end
  let(:legacy_fcl_40_pricing) do
    FactoryBot.create(:legacy_fcl_40_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle,
                      transport_category: fcl_40_transport_category)
  end
  let(:legacy_fcl_40_hq_pricing) do
    FactoryBot.create(:legacy_fcl_40_hq_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle,
                      transport_category: fcl_40_hq_transport_category)
  end
  let(:bas_charge_category) { Legacy::ChargeCategory.find_by(code: 'bas') || FactoryBot.create(:bas_charge, tenant: tenant) }

  before do
    stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
      .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json, headers: {})
    %w[ocean trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end

  describe '.grouped_schedules', :vcr do
    let(:results) { klass.grouped_schedules(schedules: schedules, shipment: target_shipment, user: user) }

    context 'with two unique pricings' do
      before do
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category)
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary2,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle2,
                          transport_category: cargo_transport_category)
      end

      it 'returns two pricing objects with unique pricing_ids' do
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
          expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
        end
      end
    end

    context 'with two unique pricings in quote shop' do
      before do
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category)
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary2,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle2,
                          transport_category: cargo_transport_category)
        allow(klass).to receive(:quotation_tool?).and_return(true)
      end

      it 'returns two pricing objects with unique pricing_ids for quote shop' do
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
          expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
        end
      end
    end

    context 'with three pricing objects with unique pricing_ids and cargo classes by closing_date (fcl)' do
      let!(:pricing1) do
        FactoryBot.create(:legacy_fcl_20_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle)
      end
      let!(:pricing2) do
        FactoryBot.create(:legacy_fcl_40_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle)
      end
      let(:schedules) do
        [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing1.tenant_vehicle,
                            itinerary: pricing1.itinerary,
                            closing_date: pricing1.expiration_date - 2.days,
                            start_date: pricing1.expiration_date + 2.days,
                            end_date: pricing1.expiration_date + 22.days),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing2.tenant_vehicle,
                            itinerary: pricing2.itinerary,
                            closing_date: pricing2.expiration_date - 2.days,
                            start_date: pricing2.expiration_date + 2.days,
                            end_date: pricing2.expiration_date + 22.days)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
      end
      let(:target_shipment) { container_shipment }

      before do
        FactoryBot.create(:legacy_fcl_40_hq_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle)
      end

      it 'returns three pricing objects with unique pricing_ids and cargo classes by closing_date (fcl)' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_20').nil? }).to eq(false)
          expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40').nil? }).to eq(false)
          expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40_hq').nil? }).to eq(false)
        end
      end
    end

    context 'with two pricing objects with unique pricing_ids by closing_date' do
      let(:pricing1) do
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category)
      end
      let(:pricing2) do
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary2,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle2,
                          transport_category: cargo_transport_category)
      end
      let(:schedules) do
        [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing1.tenant_vehicle,
                            itinerary: pricing1.itinerary,
                            closing_date: pricing1.expiration_date - 2.days,
                            start_date: pricing1.expiration_date + 2.days,
                            end_date: pricing1.expiration_date + 22.days),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing2.tenant_vehicle,
                            itinerary: pricing2.itinerary,
                            closing_date: pricing2.expiration_date - 2.days,
                            start_date: pricing2.expiration_date + 2.days,
                            end_date: pricing2.expiration_date + 22.days)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
      end

      it 'returns two pricing objects with unique pricing_ids by closing_date' do
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
          expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
        end
      end
    end

    context 'with base_pricing' do
      before do
        FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
      end

      let(:pricing1) do
        FactoryBot.create(:lcl_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle)
      end
      let(:pricing2) do
        FactoryBot.create(:lcl_pricing,
                          itinerary: itinerary2,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle2)
      end
      let(:schedules) do
        [
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing1.tenant_vehicle,
                            itinerary: pricing1.itinerary),
          FactoryBot.create(:legacy_trip,
                            tenant_vehicle: pricing2.tenant_vehicle,
                            itinerary: pricing2.itinerary)
        ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
      end

      context 'with two pricing objects with unique pricing_ids (base_pricing) on quote shop' do
        before do
          allow(klass).to receive(:quotation_tool?).and_return(true)
        end

        it 'returns two pricing objects with unique pricing_ids (base_pricing) on quote shop' do
          aggregate_failures do
            expect(results.length).to eq(2)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
            expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
          end
        end
      end

      context 'with two pricing objects with unique pricing_ids (base_pricing)' do
        it 'returns two pricing objects with unique pricing_ids (base_pricing)' do
          aggregate_failures do
            expect(results.length).to eq(2)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
            expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
          end
        end
      end

      context 'when two pricing objects with unique pricing_ids by closing_date (base_pricing)' do
        let(:schedules) do
          [
            FactoryBot.create(:legacy_trip,
                              tenant_vehicle: pricing1.tenant_vehicle,
                              itinerary: pricing1.itinerary,
                              closing_date: pricing1.expiration_date - 2.days,
                              start_date: pricing1.expiration_date + 2.days,
                              end_date: pricing1.expiration_date + 22.days),
            FactoryBot.create(:legacy_trip,
                              tenant_vehicle: pricing2.tenant_vehicle,
                              itinerary: pricing2.itinerary,
                              closing_date: pricing2.expiration_date - 2.days,
                              start_date: pricing2.expiration_date + 2.days,
                              end_date: pricing2.expiration_date + 22.days)
          ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
        end

        it 'returns two pricing objects with unique pricing_ids by closing_date (base_pricing)' do
          aggregate_failures do
            expect(results.length).to eq(2)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'lcl').nil? }).to eq(false)
            expect(results.map { |r| r.dig(:pricings_by_cargo_class, 'lcl') }.uniq.length).to eq(2)
          end
        end
      end

      context 'with three cargo classes unique pricing_ids and cargo classes (base_pricing)' do
        let(:target_shipment) { container_shipment }

        before do
          fcl_20_pricing
          fcl_40_pricing
          fcl_40_hq_pricing
        end

        it 'returns three pricing objects with unique pricing_ids and cargo classes (base_pricing)' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_20').nil? }).to eq(false)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40').nil? }).to eq(false)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40_hq').nil? }).to eq(false)
          end
        end
      end

      context 'with three cargo classes by closing_date (base_pricing)' do
        let(:target_shipment) { container_shipment }
        let(:schedules) do
          [
            FactoryBot.create(:legacy_trip,
                              tenant_vehicle: fcl_20_pricing.tenant_vehicle,
                              itinerary: fcl_20_pricing.itinerary,
                              closing_date: fcl_20_pricing.expiration_date - 2.days,
                              start_date: fcl_20_pricing.expiration_date + 2.days,
                              end_date: fcl_20_pricing.expiration_date + 22.days),
            FactoryBot.create(:legacy_trip,
                              tenant_vehicle: fcl_40_pricing.tenant_vehicle,
                              itinerary: fcl_40_pricing.itinerary,
                              closing_date: fcl_40_pricing.expiration_date - 2.days,
                              start_date: fcl_40_pricing.expiration_date + 2.days,
                              end_date: fcl_40_pricing.expiration_date + 22.days)
          ].map { |trip| OfferCalculator::Schedule.from_trip(trip) }
        end

        before do
          fcl_40_hq_pricing
          FactoryBot.create(:freight_margin,
                            itinerary_id: itinerary.id,
                            applicable: tenants_user,
                            tenant: tenants_tenant,
                            effective_date: fcl_20_pricing.effective_date - 10.days,
                            expiration_date: fcl_20_pricing.effective_date + 5.days)
        end

        it 'returns three pricing objects with unique pricing_ids and cargo classes by closing_date (base_pricing)' do
          aggregate_failures do
            expect(results.length).to eq(2)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_20').nil? }).to eq(false)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40').nil? }).to eq(false)
            expect(results.any? { |r| r.dig(:pricings_by_cargo_class, 'fcl_40_hq').nil? }).to eq(false)
          end
        end
      end
    end
  end

  describe '.sort_pricings', :vcr do
    let(:cargo_classes) { ['lcl'] }
    let(:dedicated_pricings_only) { false }
    let(:dates) do
      {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }
    end
    let(:results) do
      klass.sort_pricings(
        schedules: schedules,
        user_pricing_id: user.pricing_id,
        cargo_classes: cargo_classes,
        dates: dates,
        dedicated_pricings_only: dedicated_pricings_only
      )
    end

    context 'when legacy and  transport category (lcl)' do
      let(:target_shipment) { cargo_shipment }

      before do
        legacy_lcl_pricing
      end

      it 'returns an object containing pricings grouped by transport category (lcl)' do
        aggregate_failures do
          expect(results.keys.length).to eq(1)
          expect(results.values.first.first['id']).to eq(legacy_lcl_pricing.id)
        end
      end
    end

    context 'with legacy and transport category (fcl)' do
      let(:target_shipment) { container_shipment }
      let(:cargo_classes) { Legacy::Container::CARGO_CLASSES }

      before do
        legacy_fcl_20_pricing
        legacy_fcl_40_pricing
        legacy_fcl_40_hq_pricing
      end

      it 'returns an object containing pricings grouped by transport category (fcl)' do
        aggregate_failures do
          expect(results.keys.length).to eq(3)
          expect(results[fcl_40_hq_transport_category.id].first['id']).to eq(legacy_fcl_40_hq_pricing.id)
          expect(results[fcl_40_transport_category.id].first['id']).to eq(legacy_fcl_40_pricing.id)
          expect(results[fcl_20_transport_category.id].first['id']).to eq(legacy_fcl_20_pricing.id)
        end
      end
    end

    context 'when departure dates return nil' do
      let!(:pricing1) do
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category,
                          effective_date: Date.parse('01/01/2019'),
                          expiration_date: Date.parse('31/01/2019'))
      end
      let(:trip) do
        FactoryBot.create(:legacy_trip,
                          start_date: Date.parse('02/02/2019'),
                          end_date: Date.parse('28/02/2019'),
                          closing_date: Date.parse('28/01/2019'),
                          tenant_vehicle: tenant_vehicle,
                          itinerary: itinerary)
      end
      let(:schedules) do
        [OfferCalculator::Schedule.from_trip(trip)]
      end

      it 'returns pricings valid for closing_dates if departure dates return nil' do
        aggregate_failures do
          expect(results.keys.length).to eq(1)
          expect(results.values.first.first['id']).to eq(pricing1.id)
        end
      end
    end

    context 'with user and dedicated pricing available' do
      before do
        FactoryBot.create(:legacy_pricing,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category,
                          effective_date: Date.parse('01/01/2019'),
                          expiration_date: Date.parse('31/01/2019'))
      end

      let!(:pricing1) do
        FactoryBot.create(:legacy_pricing,
                          user: user,
                          itinerary: itinerary,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category,
                          effective_date: Date.parse('01/01/2019'),
                          expiration_date: Date.parse('31/01/2019'))
      end
      let(:trip) do
        FactoryBot.create(:legacy_trip,
                          start_date: Date.parse('02/02/2019'),
                          end_date: Date.parse('28/02/2019'),
                          closing_date: Date.parse('28/01/2019'),
                          tenant_vehicle: tenant_vehicle,
                          itinerary: itinerary)
      end
      let(:schedules) do
        [OfferCalculator::Schedule.from_trip(trip)]
      end
      let(:dedicated_pricings_only) { true }

      it 'returns pricings valid for closing_dates and user if dedicated pricing available' do
        aggregate_failures do
          expect(results.keys.length).to eq(1)
          expect(results.values.first.first['id']).to eq(pricing1.id)
        end
      end
    end
  end

  describe '.sort_schedule_permutations', :vcr do
    it 'returns an object containing schedules grouped by pricing permutation' do
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)

      results = service.sort_schedule_permutations(schedules: schedules)
      aggregate_failures do
        expect(results.keys.length).to eq(2)
        expect(results.values.map(&:length).uniq).to eq([1])
      end
    end
  end

  describe '.perform (legacy)', :vcr do
    let(:no_trucking_data) { { trucking_pricings: {}, metadata: [] } }
    let(:target_trucking_data) { no_trucking_data }
    let(:klass) { described_class.new(shipment: target_shipment, sandbox: nil) }
    let(:results) { klass.perform(schedules, target_trucking_data, user) }

    before do
      FactoryBot.create(:legacy_lcl_pricing,
                        itinerary: itinerary,
                        tenant_vehicle: tenant_vehicle,
                        transport_category: cargo_transport_category)
      FactoryBot.create(:legacy_fcl_20_pricing,
                        itinerary: itinerary,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle,
                        transport_category: fcl_20_transport_category)
      FactoryBot.create(:legacy_fcl_40_pricing,
                        itinerary: itinerary,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle,
                        transport_category: fcl_40_transport_category)
      FactoryBot.create(:legacy_fcl_40_hq_pricing,
                        itinerary: itinerary,
                        tenant: tenant,
                        tenant_vehicle: tenant_vehicle,
                        transport_category: fcl_40_hq_transport_category)
    end

    it 'returns an object with two quotes with subtotals and grand totals' do
      service = described_class.new(shipment: cargo_shipment, sandbox: nil)
      results = service.perform(schedules, no_trucking_data, user)
      aggregate_failures do
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end
    end

    it 'returns an object with two quotes with subtotals and grand totals w/ aggregated cargo' do
      service = described_class.new(shipment: agg_cargo_shipment, sandbox: nil)
      results = service.perform(schedules, no_trucking_data, user)
      aggregate_failures do
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end
    end

    it 'returns an object with two quotes with subtotals and grand totals w/ containers' do
      service = described_class.new(shipment: container_shipment, sandbox: nil)
      results = service.perform(schedules, no_trucking_data, user)
      aggregate_failures do
        expect(results.count).to eq(1)
        expect(results.first[:quote][:total][:value]).to be_truthy
        expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
      end
    end
  end

  describe '.perform (base pricing)', :vcr do
    before do
      lcl_pricing
      fcl_20_pricing
      fcl_40_pricing
      fcl_40_hq_pricing
      FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
    end

    context 'without margins (regular)' do
      let(:target_shipment) { cargo_shipment }

      it 'returns an object with two quotes with subtotals and grand totals' do
        aggregate_failures do
          expect(results.count).to eq(1)
          expect(results.first[:quote][:total][:value]).to be_truthy
          expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
        end
      end
    end

    context 'without margins (agg cargo)' do
      let(:target_shipment) { agg_cargo_shipment }

      it 'returns an object with two quotes with subtotals and grand totals w/ aggregated cargo' do
        aggregate_failures do
          expect(results.count).to eq(1)
          expect(results.first[:quote][:total][:value]).to be_truthy
          expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
        end
      end
    end

    context 'without margins (containers)' do
      let(:target_shipment) { container_shipment }

      it 'returns an object with two quotes with subtotals and grand totals w/ containers' do
        service = described_class.new(shipment: agg_cargo_shipment, sandbox: nil)
        results = service.perform(schedules, no_trucking_data, user)
        aggregate_failures do
          expect(results.count).to eq(1)
          expect(results.first[:quote][:total][:value]).to be_truthy
          expect(results.first[:quote][:cargo][:total][:value]).to be_truthy
        end
      end
    end

    context 'with margins and breakdowns (standard)' do
      before do
        FactoryBot.create(:pricings_margin,
                          operator: '%',
                          value: 10,
                          itinerary_id: itinerary.id,
                          applicable: group,
                          tenant: tenants_tenant)
      end

      let(:target_shipment) { cargo_shipment }
      let!(:target_result) { results.first }

      it 'returns an object with two quotes with subtotals and grand totals w/ % margins' do
        aggregate_failures do
          expect(results.count).to eq(1)
          expect(target_result.dig(:quote, :total, :value)).to be_truthy
          expect(target_result.dig(:quote, :cargo, :total, :value)).to be_truthy
        end
      end

      it 'returns an object with Metadatum w/ % margins' do
        aggregate_failures do
          metadatum = Pricings::Metadatum.find_by(id: target_result.dig(:meta, :metadata_id))
          expect(metadatum).to be_present
          expect(metadatum.breakdowns.pluck(:charge_category_id).uniq).to match_array(lcl_pricing.fees.pluck(:charge_category_id))
        end
      end
    end

    context 'with margins and breakdowns (total margins)' do
      before do
        FactoryBot.create(:pricings_margin,
                          operator: '+',
                          value: 100,
                          itinerary_id: itinerary.id,
                          applicable: group,
                          tenant: tenants_tenant)
      end

      let(:target_shipment) { cargo_shipment }
      let!(:target_result) { results.first }

      it 'returns an object with two quotes with subtotals and grand totals w/ total margins' do
        aggregate_failures do
          expect(results.count).to eq(1)
          expect(target_result.dig(:quote, :total, :value)).to be_truthy
          expect(target_result.dig(:quote, :cargo, :total, :value)).to be_truthy
        end
      end

      it 'returns an object with Metadatum w/ total margins' do
        aggregate_failures do
          metadatum = Pricings::Metadatum.find_by(id: target_result.dig(:meta, :metadata_id))
          expect(metadatum).to be_present
          expect(metadatum.breakdowns.pluck(:charge_category_id).uniq).to match_array(lcl_pricing.fees.pluck(:charge_category_id))
          expect(metadatum.breakdowns.map { |b| b.margin&.operator }.compact.uniq).to match_array(['+'])
        end
      end
    end

    context 'with margins and breakdowns (absolute margins)' do
      before do
        FactoryBot.create(:freight_margin, pricing: lcl_pricing, tenant: tenants_tenant, applicable: tenants_user, operator: '%', value: 0).tap do |tapped_margin|
          FactoryBot.create(:bas_margin_detail,
                            margin: tapped_margin,
                            value: 25,
                            operator: '&',
                            charge_category: bas_charge_category)
        end
      end

      let(:target_shipment) { cargo_shipment }
      let!(:target_result) { results.first }

      it 'returns an object with two quotes with subtotals and grand totals w/ total margins' do
        aggregate_failures do
          expect(results.count).to eq(1)
          expect(target_result.dig(:quote, :total, :value)).to be_truthy
          expect(target_result.dig(:quote, :cargo, :total, :value)).to be_truthy
        end
      end

      it 'returns an object with Metadatum w/ total margins' do
        aggregate_failures do
          metadatum = Pricings::Metadatum.find_by(id: target_result.dig(:meta, :metadata_id))
          expect(metadatum).to be_present
          expect(metadatum.breakdowns.pluck(:charge_category_id).uniq).to match_array(lcl_pricing.fees.pluck(:charge_category_id))
          expect(metadatum.breakdowns.map { |b| Pricings::Detail.find_by(id: b.margin_id)&.operator }.compact.uniq).to match_array(['&'])
        end
      end
    end
  end

  describe 'errors' do
    context 'without a any schedules' do
      it 'raises NoValidSchedules when there are no schedules' do
        expect { klass.perform([], target_trucking_data, user) }.to raise_error(OfferCalculator::Calculator::NoValidSchedules)
      end
    end

    context 'with charge calculator errors' do
      before do
        FactoryBot.create(:legacy_lcl_pricing,
                          itinerary: itinerary,
                          tenant_vehicle: tenant_vehicle,
                          transport_category: cargo_transport_category)
        allow(klass).to receive(:handle_group_result).and_return([{ error: OfferCalculator::Calculator::InvalidFreightResult }])
      end

      it 'raises InvalidFreightResult when there are no schedules' do
        expect { klass.perform(schedules, target_trucking_data, user) }.to raise_error(OfferCalculator::Calculator::InvalidFreightResult)
      end
    end

    context 'without a any pricings' do
      before do
        allow(klass).to receive(:grouped_schedules).and_return([])
      end

      it 'raises NoValidPricings when there are no schedules' do
        expect { results }.to raise_error(OfferCalculator::Calculator::NoValidPricings)
      end
    end
  end
end
