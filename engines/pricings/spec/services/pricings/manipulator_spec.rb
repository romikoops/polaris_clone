# frozen_string_literal: true

require 'rails_helper'
require 'timecop'
RSpec.describe Pricings::Manipulator do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:scope) { FactoryBot.create(:tenants_scope, content: {}, target: tenants_tenant)}
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }

  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
  let!(:membership_1) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_20_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_hq_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:agg_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:lcl_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id) }
  let(:fcl_20_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_hq_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40_hq', shipment_id: fcl_40_hq_shipment.id) }

  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, tenant: tenant) }
  let!(:solas_charge_category) { FactoryBot.create(:solas_charge, tenant: tenant) }
  let!(:bas_charge_category) { FactoryBot.create(:bas_charge, tenant: tenant) }
  let!(:baf_charge_category) { FactoryBot.create(:baf_charge, tenant: tenant) }
  let(:agg_cargo) { FactoryBot.create(:legacy_aggregated_cargo, shipment_id: agg_shipment.id) }
  let(:consolidated_cargo) do
    {
      id: 'ids',
      dimension_x: 240,
      dimension_y: 160,
      dimension_z: 240,
      volume: 3.748,
      payload_in_kg: 600,
      cargo_class: 'lcl',
      chargeable_weight: 3748,
      num_of_items: 2,
      quantity: 1
    }
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
  let(:wm_rate_basis) { double('WM Rate basis', external_code: 'PER_WM', internal_code: 'PER_WM') }
  let(:itinerary_1) { FactoryBot.create(:default_itinerary, tenant: tenant) }

  context 'freight pricings' do
    describe '.perform' do
      it 'returns the manipulated freight pricing attached to the user' do
        lcl_pricing_1 = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin, pricing: lcl_pricing_1, tenant: tenants_tenant, applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_1.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the user with multiple margins' do
        lcl_pricing_1 = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin,
                          pricing: lcl_pricing_1,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 10.days).end_of_day)
        FactoryBot.create(:freight_margin,
                          itinerary_id: lcl_pricing_1.itinerary_id,
                          tenant: tenants_tenant,
                          applicable: group_1,
                          value: 10,
                          operator: '+',
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 30.days).end_of_day)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        manipulated_pricings.sort_by! { |m| m['effective_date'] }

        expect(manipulated_pricings.pluck(:id).uniq).to eq([lcl_pricing_1.id])
        expect(manipulated_pricings.flat_map {|pricing| pricing['data'].keys }.uniq).to eq(['BAS'])
        expect(manipulated_pricings.map {|pricing| pricing.dig('data', 'BAS', 'rate') }).to eq([25.0, 37.5, 35.0, 25.0])
        expect(manipulated_pricings.map {|pricing| pricing.dig('data', 'BAS', 'rate_basis') }.uniq).to eq(['PER_WM'])
      end

      it 'returns the manipulated freight pricing attached to the group' do
        group_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin, pricing: group_pricing, tenant: tenants_tenant, applicable: group_1)
        manipulated_pricings = described_class.new(
          type: :freight_margin,
          user: tenants_user,
          args: {
            sandbox: nil,
            pricing: group_pricing,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the group without pricing' do
        group_pricing = FactoryBot.create(:lcl_pricing,
                                          tenant_vehicle: tenant_vehicle_1,
                                          tenant: tenant,
                                          itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin,
                          itinerary_id: group_pricing.itinerary_id,
                          tenant_vehicle_id: group_pricing.tenant_vehicle_id,
                          cargo_class: group_pricing.cargo_class,
                          tenant: tenants_tenant,
                          applicable: group_1)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns multiple manipulated freight pricings when margins overlap attached to the group without pricing' do
        Timecop.freeze(Time.now) do
          group_pricing = FactoryBot.create(:lcl_pricing,
                                            tenant_vehicle: tenant_vehicle_1,
                                            tenant: tenant,
                                            itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
          trips = [1, 3, 10, 13].map do |num|
            base_date = num.days.from_now
            FactoryBot.create(:legacy_trip,
                              itinerary: group_pricing.itinerary,
                              tenant_vehicle: group_pricing.tenant_vehicle,
                              closing_date: base_date - 4.days,
                              start_date: base_date,
                              end_date: base_date + 30.days)
          end
          schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
          margin_a = FactoryBot.create(:freight_margin,
                                       pricing: group_pricing,
                                       effective_date: Date.today - 3.days,
                                       expiration_date: (Date.today + 10.days).end_of_day,
                                       tenant: tenants_tenant,
                                       applicable: group_1)
          margin_b = FactoryBot.create(:freight_margin,
                                       pricing: group_pricing,
                                       effective_date: Date.today + 8.days,
                                       expiration_date: (Date.today + 22.days).end_of_day,
                                       tenant: tenants_tenant,
                                       value: 0.5,
                                       applicable: group_1)
          manipulated_pricings = described_class.new(
            user: tenants_user,
            type: :freight_margin,
            args: {
              sandbox: nil,
              itinerary_id: group_pricing.itinerary_id,
              tenant_vehicle_id: group_pricing.tenant_vehicle_id,
              cargo_class: group_pricing.cargo_class,
              schedules: schedules,
              shipment: lcl_shipment
            }
          ).perform
          manipulated_pricings.sort_by! { |m| m['effective_date'] }

          expect(manipulated_pricings[0]['id']).to eq(group_pricing.id)
          expect(manipulated_pricings[0]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
          expect(manipulated_pricings[0]['data'].keys).to eq(['BAS'])
          expect(manipulated_pricings[0].dig('data', 'BAS', 'rate')).to eq(27.5)
          expect(manipulated_pricings[0].dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')

          expect(manipulated_pricings[1]['id']).to eq(group_pricing.id)
          expect(manipulated_pricings[1]['effective_date']).to eq(margin_b.effective_date)
          expect(manipulated_pricings[1]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
          expect(manipulated_pricings[1]['data'].keys).to eq(['BAS'])
          expect(manipulated_pricings[1].dig('data', 'BAS', 'rate')).to eq(41.25)
          expect(manipulated_pricings[1].dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')

          expect(manipulated_pricings[2]['id']).to eq(group_pricing.id)
          expect(manipulated_pricings[2]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
          expect(manipulated_pricings[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)
          expect(manipulated_pricings[2]['data'].keys).to eq(['BAS'])
          expect(manipulated_pricings[2].dig('data', 'BAS', 'rate')).to eq(37.5)
          expect(manipulated_pricings[2].dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
        end
      end

      it 'returns the manipulated freight pricing attached to the group via company' do
        company = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
        tenants_user.company_id = company.id
        tenants_user.save
        company_group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
        FactoryBot.create(:tenants_membership, member: company, group: company_group)
        group_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin, pricing: group_pricing, tenant: tenants_tenant, applicable: company_group)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: group_pricing,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing with specific detail attached to the user' do
        lcl_pricing_2 = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1)
        FactoryBot.create(:fee_per_wm, tenant: tenant, charge_category: bas_charge_category, pricing: lcl_pricing_2, rate: 40)
        user_base_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing_2, tenant: tenants_tenant, applicable: tenants_user)
        FactoryBot.create(:bas_margin_detail, margin: user_base_margin, value: 0.25, charge_category: bas_charge_category)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: lcl_pricing_2.itinerary,
                            tenant_vehicle: lcl_pricing_2.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_2,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_2.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(50)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing with one specific detail and general attached to the user' do
        lcl_pricing_3 = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: lcl_pricing_3.itinerary,
                            tenant_vehicle: lcl_pricing_3.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:fee_per_wm, tenant: tenant, charge_category: bas_charge_category, pricing: lcl_pricing_3, rate: 40)
        FactoryBot.create(:fee_per_wm, tenant: tenant, charge_category: baf_charge_category, pricing: lcl_pricing_3, rate: 40)
        user_multi_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing_3, tenant: tenants_tenant, applicable: tenants_user)
        FactoryBot.create(:bas_margin_detail, margin: user_multi_margin, value: 0.25, charge_category: bas_charge_category)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_3,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_3.id)
        expect(manipulated_pricings.first['data'].keys).to eq(%w(BAS BAF))
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(50)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
        expect(manipulated_pricings.first.dig('data', 'BAF', 'rate')).to eq(44)
        expect(manipulated_pricings.first.dig('data', 'BAF', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the user with a range' do
        lcl_range_pricing = FactoryBot.create(:lcl_range_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: lcl_range_pricing.itinerary,
                            tenant_vehicle: lcl_range_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin, pricing: lcl_range_pricing, tenant: tenants_tenant, applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_range_pricing,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(lcl_range_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'range', 0, 'rate')).to eq(11)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_KG_RANGE')
      end

      it 'returns the manipulated freight pricing attached to the user for addition margin' do
        lcl_pricing_4 = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: lcl_pricing_4.itinerary,
                            tenant_vehicle: lcl_pricing_4.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin, pricing: lcl_pricing_4, tenant: tenants_tenant, applicable: tenants_user, value: 10, operator: '+')
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_4,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_4.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(35)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the tenant without pricing' do
        group_pricing = FactoryBot.create(:lcl_pricing,
                                          tenant_vehicle: tenant_vehicle_1,
                                          tenant: tenant,
                                          itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin,
                          itinerary_id: group_pricing.itinerary_id,
                          tenant_vehicle_id: group_pricing.tenant_vehicle_id,
                          cargo_class: group_pricing.cargo_class,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        manipulated_pricings.sort_by! { |m| m['effective_date'] }
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the tenant with itinerary only' do
        group_pricing = FactoryBot.create(:lcl_pricing,
                                          tenant_vehicle: tenant_vehicle_1,
                                          tenant: tenant,
                                          itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin,
                          itinerary_id: group_pricing.itinerary_id,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the tenant with default_for' do
        group_pricing = FactoryBot.create(:lcl_pricing,
                                          tenant_vehicle: tenant_vehicle_1,
                                          tenant: tenant,
                                          itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(25)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to the tenant with nothing else' do
        group_pricing = FactoryBot.create(:lcl_pricing,
                                          tenant_vehicle: tenant_vehicle_1,
                                          tenant: tenant,
                                          itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns the manipulated freight pricing attached to hub and cargo class' do
        group_pricing = FactoryBot.create(:lcl_pricing,
                                          tenant_vehicle: tenant_vehicle_1,
                                          tenant: tenant,
                                          itinerary: FactoryBot.create(:default_itinerary, tenant: tenant))
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: group_pricing.itinerary,
                            tenant_vehicle: group_pricing.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:freight_margin,
                          tenant: tenants_tenant,
                          origin_hub: group_pricing.itinerary.hubs.first,
                          cargo_class: group_pricing.cargo_class,
                          applicable: tenants_tenant)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['BAS'])
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'BAS', 'rate_basis')).to eq('PER_WM')
      end
    end
  end

  context 'local_charges' do
    describe '.perform' do
      it 'returns the manipulated local_charge (export) attached to the user' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge (export) attached to the user not covering entire validity' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          effective_date: local_charge.effective_date + 10.days,
                          expiration_date: local_charge.effective_date + 20.days,
                          applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        manipulated_pricings.sort_by! { |m| m['effective_date'] }
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(17.5)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.last['id']).to eq(local_charge.id)
        expect(manipulated_pricings.last['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.last.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.last.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge (import) attached to the user' do
        hub = itinerary_1.last_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'import',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:import_margin,
                          destination_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :import_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge (export) attached to the user with multiple margins' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        margin_a = FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 10.days).end_of_day)
        margin_b = FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          applicable: group_1,
                          value: 10,
                          operator: '+',
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 30.days).end_of_day)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        manipulated_pricings.sort_by! { |m| m['effective_date'] }
        expect(manipulated_pricings.map {|mp| mp['id'] }.uniq).to match_array([local_charge.id])
        expect(manipulated_pricings.map {|mp| mp.dig('fees', 'SOLAS', 'value') }).to match_array([17.5, 29.25, 27.5, 17.5])
        expect(manipulated_pricings[0]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
        expect(manipulated_pricings[1]['effective_date']).to eq(margin_b.effective_date)
        expect(manipulated_pricings[1]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
        expect(manipulated_pricings[2]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
        expect(manipulated_pricings[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)

      end
      it 'returns the manipulated local_charge (import) attached to the user with multiple margins' do
        hub = itinerary_1.last_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'import',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:import_margin,
                          destination_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 10.days).end_of_day)
        FactoryBot.create(:import_margin,
                          destination_hub: hub,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenants_tenant,
                          applicable: group_1,
                          value: 10,
                          operator: '+',
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 30.days).end_of_day)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :import_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        manipulated_pricings.map {|mp| mp.dig('fees', 'PUF', 'value') }
        expect(manipulated_pricings.pluck(:id).uniq).to eq([local_charge.id])
        expect(manipulated_pricings.flat_map {|pricing| pricing['fees'].keys }.uniq).to eq(['SOLAS'])
        expect(manipulated_pricings.map {|pricing| pricing.dig('fees', 'SOLAS', 'value') }).to eq([17.5, 29.25, 27.5, 17.5])
        expect(manipulated_pricings.map {|pricing| pricing.dig('fees', 'SOLAS', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
      end

      it 'returns the manipulated local_charge attached to the group' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: group_1)
        manipulated_pricings = described_class.new(
          type: :export_margin,
          user: tenants_user,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns multiple manipulated local_charges when margins overlap attached to the group without pricing' do
        Timecop.freeze(Time.now) do
          hub = itinerary_1.first_stop.hub
          local_charge = FactoryBot.create(:legacy_local_charge,
                                           hub: hub,
                                           direction: 'export',
                                           tenant_vehicle: tenant_vehicle_1,
                                           tenant: tenant)
          trips = [1, 3, 10, 13].map do |num|
            base_date = num.days.from_now
            FactoryBot.create(:legacy_trip,
                              itinerary: itinerary_1,
                              tenant_vehicle: tenant_vehicle_1,
                              closing_date: base_date - 4.days,
                              start_date: base_date,
                              end_date: base_date + 30.days)
          end
          schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
          margin_a = FactoryBot.create(:export_margin,
                                       origin_hub: hub,
                                       tenant_vehicle: tenant_vehicle_1,
                                       effective_date: (Date.today - 3.days).beginning_of_day,
                                       expiration_date: (Date.today + 2.days).end_of_day,
                                       tenant: tenants_tenant,
                                       applicable: group_1)
          margin_b = FactoryBot.create(:export_margin,
                                       origin_hub: hub,
                                       tenant_vehicle: tenant_vehicle_1,
                                       effective_date: (Date.today + 8.days).beginning_of_day,
                                       expiration_date: (Date.today + 22.days).end_of_day,
                                       tenant: tenants_tenant,
                                       value: 0.5,
                                       applicable: group_1)
          manipulated_pricings = described_class.new(
            user: tenants_user,
            type: :export_margin,
            args: {
              sandbox: nil,
              local_charge: local_charge,
              schedules: schedules,
              shipment: lcl_shipment
            }
          ).perform

          manipulated_pricings.sort_by! { |m| m['effective_date'] }
          expect(manipulated_pricings.pluck(:id).uniq).to eq([local_charge.id])
          expect(manipulated_pricings.flat_map {|pricing| pricing['fees'].keys }.uniq).to eq(['SOLAS'])
          expect(manipulated_pricings.map {|pricing| pricing.dig('fees', 'SOLAS', 'value') }).to eq([19.25, 17.5, 26.25, 17.5])
          expect(manipulated_pricings.map {|pricing| pricing.dig('fees', 'SOLAS', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
          expect(manipulated_pricings[0]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
          expect(manipulated_pricings[1]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
          expect(manipulated_pricings[1]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
          expect(manipulated_pricings[2]['effective_date']).to eq(margin_b.effective_date)
          expect(manipulated_pricings[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)
        end
      end

      it 'returns the manipulated local_charge attached to the group via company' do
        company = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
        tenants_user.company_id = company.id
        tenants_user.save
        company_group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
        FactoryBot.create(:tenants_membership, member: company, group: company_group)
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin, origin_hub: hub, tenant_vehicle: tenant_vehicle_1, tenant: tenants_tenant, applicable: company_group)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge with specific detail attached to the user' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        user_base_margin = FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user, value: 0)
        FactoryBot.create(:bas_margin_detail, margin: user_base_margin, value: 0.25, charge_category: solas_charge_category)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(21.875)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge with one specific detail and general attached to the user' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant,
                                         fees: {
                                           'SOLAS' => {
                                             'key' => 'SOLAS',
                                             'max' => nil,
                                             'min' => 17.5,
                                             'name' => 'SOLAS',
                                             'value' => 17.5,
                                             'currency' => 'EUR',
                                             'rate_basis' => 'PER_SHIPMENT'
                                           },
                                           'BAF' => {
                                             'key' => 'BAF',
                                             'max' => nil,
                                             'min' => 20,
                                             'name' => 'Bunker Adjustment Fee',
                                             'value' => 20,
                                             'currency' => 'EUR',
                                             'rate_basis' => 'PER_SHIPMENT'
                                           }
                                         })
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        user_multi_margin = FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        FactoryBot.create(:bas_margin_detail, margin: user_multi_margin, value: 0.25, charge_category: baf_charge_category)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(%w(SOLAS BAF))
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first.dig('fees', 'BAF', 'value')).to eq(25)
        expect(manipulated_pricings.first.dig('fees', 'BAF', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge attached to the user with a range' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant,
                                         fees: {
                                           "SOLAS": {
                                             "key": 'SOLAS',
                                             "max": nil,
                                             "min": 17.5,
                                             "name": 'SOLAS',
                                             "value": 17.5,
                                             "currency": 'EUR',
                                             "rate_basis": 'PER_CBM_TON_RANGE',
                                             "range": [
                                               { 'min': 0, 'max': 10, 'cbm': 10, 'ton': 40 }
                                             ]
                                           }
                                         })
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'range', 0, 'cbm')).to eq(11)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'range', 0, 'ton')).to eq(44)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_CBM_TON_RANGE')
      end

      it 'returns the manipulated local_charge attached to the user for addition margin' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user, value: 10, operator: '+')
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(27.5)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns the manipulated local_charge attached to the tenant with nothing else' do
        hub = itinerary_1.first_stop.hub
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: itinerary_1,
                            tenant_vehicle: tenant_vehicle_1,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
        FactoryBot.create(:export_margin,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end
    end
  end
  context 'trucking' do
    describe '.perform' do
      it 'returns the manipulated trucking pricing attached to the user' do
        hub = itinerary_1.first_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :trucking_pre_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days
          }
        ).perform

        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(275)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        expect(manipulated_pricings.first['rates'].dig('kg', 16, 'rate', 'value')).to eq(28.6)
      end

      it 'returns the manipulated trucking pricing attached to the user with multiple margins' do
        hub = itinerary_1.first_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

        FactoryBot.create(:trucking_pre_margin,
                          destination_hub: hub,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 10.days).end_of_day)
        FactoryBot.create(:trucking_pre_margin,
                          destination_hub: hub,
                          tenant: tenants_tenant,
                          applicable: group_1,
                          value: 10,
                          operator: '+',
                          effective_date: (Date.today + 1.day).beginning_of_day,
                          expiration_date: (Date.today + 30.days).end_of_day)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :trucking_pre_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days
          }
        ).perform
        manipulated_pricings.sort_by! { |m| m['effective_date'] }

        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.map {|pricing| pricing.dig('fees', 'PUF', 'value') }).to match_array([250.0, 285.0, 260.0, 250.0])
        expect(manipulated_pricings.map {|pricing| pricing.dig('fees', 'PUF', 'rate_basis')}.uniq).to eq(['PER_SHIPMENT'])
        expect(manipulated_pricings.map {|pricing| pricing.dig('rates', 'kg', 0, 'rate', 'value') }).to eq([237.5, 271.25, 281.25, 281.25])
      end

      it 'returns the manipulated trucking pricing attached to the group' do
        hub = itinerary_1.first_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, tenant: tenants_tenant, applicable: group_1)
        manipulated_pricings = described_class.new(
          type: :trucking_pre_margin,
          user: tenants_user,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(275)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        expect(manipulated_pricings.first['rates'].dig('kg', 16, 'rate', 'value')).to eq(28.6)
      end

      it 'returns multiple manipulated trucking pricings when margins overlap attached to the group without pricing' do
        Timecop.freeze(Time.now) do
          hub = itinerary_1.first_stop.hub
          trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

          FactoryBot.create(:trucking_pre_margin,
                            destination_hub: hub,
                            effective_date: (Date.today).beginning_of_day,
                            expiration_date: (Date.today + 12.days).end_of_day,
                            tenant: tenants_tenant,
                            applicable: group_1)
          FactoryBot.create(:trucking_pre_margin,
                            destination_hub: hub,
                            effective_date: (Date.today + 10.days).beginning_of_day,
                            expiration_date: (Date.today + 22.days).end_of_day,
                            tenant: tenants_tenant,
                            value: 0.5,
                            applicable: group_1)
          manipulated_pricings = described_class.new(
            user: tenants_user,
            type: :trucking_pre_margin,
            args: {
              sandbox: nil,
              trucking_pricing: trucking_pricing,
              shipment: lcl_shipment,
              date: Date.today + 5.days
            }
          ).perform
          manipulated_pricings.sort_by! { |m| m['effective_date'] }

          expect(manipulated_pricings.map {|tp| tp['id'] }.uniq).to match_array([trucking_pricing.id])
          expect(manipulated_pricings.map {|mp| mp[:rates].dig('kg', 0, 'rate', 'value') }).to match_array([0.26125e3, 0.4310625e3, 0.64659375e3, 0.64659375e3])
          expect(manipulated_pricings.map {|mp| mp.dig('fees', 'PUF', 'value') }).to match_array([0.275e3, 0.4125e3, 0.375e3, 0.25e3])

        end
      end

      it 'returns the manipulated trucking pricing attached to the group via company' do
        company = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
        tenants_user.company_id = company.id
        tenants_user.save
        company_group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
        FactoryBot.create(:tenants_membership, member: company, group: company_group)
        hub = itinerary_1.last_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'on')
        FactoryBot.create(:trucking_on_margin, origin_hub: hub, tenant: tenants_tenant, applicable: company_group)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :trucking_on_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(275)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        expect(manipulated_pricings.first['rates'].dig('kg', 16, 'rate', 'value')).to eq(28.6)
      end

      it 'returns the manipulated trucking pricing with specific detail attached to the user' do
        hub = itinerary_1.last_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'on')
        user_base_margin = FactoryBot.create(:trucking_on_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        FactoryBot.create(:pricings_detail, margin: user_base_margin, value: 0.25, charge_category: puf_charge_category)
        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :trucking_on_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(312.5)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        expect(manipulated_pricings.first['rates'].dig('kg', 16, 'rate', 'value')).to eq(28.6)
      end

      it 'returns the manipulated trucking pricing with range fee' do
        hub = itinerary_1.last_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking,
                                             hub: hub,
                                             tenant: tenant,
                                             carriage: 'on',
                                             fees: {
                                               "PUF": {
                                                 "key": 'PUF',
                                                 "max": nil,
                                                 "min": 17.5,
                                                 "name": 'PUF',
                                                 "value": 17.5,
                                                 "currency": 'EUR',
                                                 "rate_basis": 'PER_CBM_TON_RANGE',
                                                 "range": [
                                                   { 'min': 0, 'max': 10, 'cbm': 10, 'ton': 40 }
                                                 ]
                                               }
                                             })
        user_base_margin = FactoryBot.create(:trucking_on_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        FactoryBot.create(:pricings_detail, margin: user_base_margin, value: 0.25, charge_category: puf_charge_category)

        manipulated_pricings = described_class.new(
          user: tenants_user,
          type: :trucking_on_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days
          }
        ).perform
        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(21.875)
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        expect(manipulated_pricings.first['rates'].dig('kg', 16, 'rate', 'value')).to eq(28.6)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'range', 0, 'cbm')).to eq(12.5)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'range', 0, 'ton')).to eq(50)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_CBM_TON_RANGE')
      end
    end
  end

  describe '.find_applicable_margins' do
    it 'returns the applicable margin attached to the user' do
      lcl_pricing_user = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
      trips = [1, 3].map do |num|
        base_date = num.days.from_now
        FactoryBot.create(:legacy_trip,
                          itinerary: lcl_pricing_user.itinerary,
                          tenant_vehicle: lcl_pricing_user.tenant_vehicle,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
      end
      schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
      user_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing_user, tenant: tenants_tenant, applicable: tenants_user)
      margins = described_class.new(
        user: tenants_user,
        type: :freight_margin,
        args: {
          sandbox: nil,
          pricing: lcl_pricing_user,
          schedules: schedules,
          shipment: lcl_shipment
        }
      ).find_applicable_margins
      expect(margins.first[:margin]).to eq(user_margin)
    end

    it 'returns the applicable margin attached to the tenant when the user has none' do
      lcl_pricing_tenant = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
      trips = [1, 3].map do |num|
        base_date = num.days.from_now
        FactoryBot.create(:legacy_trip,
                          itinerary: lcl_pricing_tenant.itinerary,
                          tenant_vehicle: lcl_pricing_tenant.tenant_vehicle,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
      end
      schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
      tenant_margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing_tenant, tenant: tenants_tenant, applicable: tenants_tenant)
      margins = described_class.new(
        user: tenants_user,
        type: :freight_margin,
        args: {
          sandbox: nil,
          pricing: lcl_pricing_tenant,
          schedules: schedules,
          shipment: lcl_shipment
        }
      ).find_applicable_margins
      expect(margins.first[:margin]).to eq(tenant_margin)
    end
  end
end
