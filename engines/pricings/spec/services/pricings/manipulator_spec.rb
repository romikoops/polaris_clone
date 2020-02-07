# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Manipulator do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:scope) { FactoryBot.create(:tenants_scope, content: {}, target: tenants_tenant) }
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
  let!(:trucking_pre_charge_category) { FactoryBot.create(:trucking_pre_charge, tenant: tenant) }
  let!(:trucking_on_charge_category) { FactoryBot.create(:trucking_on_charge, tenant: tenant) }
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
    %w[ocean air rail truck trucking local_charge].flat_map do |mot|
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_1.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        manipulated_pricings.sort_by! { |m| m['effective_date'] }

        expect(manipulated_pricings.pluck(:id).uniq).to eq([lcl_pricing_1.id])
        expect(manipulated_pricings.flat_map { |pricing| pricing['data'].keys }.uniq).to eq(['bas'])
        expect(manipulated_pricings.map { |pricing| pricing.dig('data', 'bas', 'rate') }).to eq([25.0, 27.5, 25.0, 25.0])
        expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to eq([{}, { 'bas' => 0.1e2 }, { 'bas' => 0.1e2 }, {}])
        expect(manipulated_pricings.map { |pricing| pricing.dig('data', 'bas', 'rate_basis') }.uniq).to eq(['PER_WM'])
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
        manipulated_pricings_and_metadata = described_class.new(
          type: :freight_margin,
          target: tenants_user,
          tenant: tenants_tenant,
          args: {
            sandbox: nil,
            pricing: group_pricing,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
      end

      it 'returns multiple manipulated freight pricings when margins overlap attached to the group without pricing' do
        Timecop.freeze(Time.zone.now) do
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
          manipulated_pricings_and_metadata = described_class.new(
            target: tenants_user,
            tenant: tenants_tenant,
            type: :freight_margin,
            args: {
              sandbox: nil,
              itinerary_id: group_pricing.itinerary_id,
              tenant_vehicle_id: group_pricing.tenant_vehicle_id,
              cargo_class: group_pricing.cargo_class,
              schedules: schedules,
              shipment: lcl_shipment,
              without_meta: true
            }
          ).perform
          manipulated_pricings = manipulated_pricings_and_metadata.first
          manipulated_pricings.sort_by! { |m| m['effective_date'] }

          expect(manipulated_pricings[0]['id']).to eq(group_pricing.id)
          expect(manipulated_pricings[0]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
          expect(manipulated_pricings.dig(0, 'data').keys).to eq(['bas'])
          expect(manipulated_pricings.dig(0, 'data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.dig(0, 'data', 'bas', 'rate_basis')).to eq('PER_WM')

          expect(manipulated_pricings[1]['id']).to eq(group_pricing.id)
          expect(manipulated_pricings[1]['effective_date']).to eq(margin_b.effective_date)
          expect(manipulated_pricings[1]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
          expect(manipulated_pricings.dig(1, 'data').keys).to eq(['bas'])
          expect(manipulated_pricings.dig(1, 'data', 'bas', 'rate')).to eq(41.25)
          expect(manipulated_pricings.dig(1, 'data', 'bas', 'rate_basis')).to eq('PER_WM')

          expect(manipulated_pricings[2]['id']).to eq(group_pricing.id)
          expect(manipulated_pricings[2]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
          expect(manipulated_pricings[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)
          expect(manipulated_pricings.dig(2, 'data').keys).to eq(['bas'])
          expect(manipulated_pricings.dig(2, 'data', 'bas', 'rate')).to eq(37.5)
          expect(manipulated_pricings.dig(2, 'data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: group_pricing,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_2,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_2.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(50)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_3,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_3.id)
        expect(manipulated_pricings.first['data'].keys).to eq(%w[bas baf])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(50)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        expect(manipulated_pricings.first.dig('data', 'baf', 'rate')).to eq(44)
        expect(manipulated_pricings.first.dig('data', 'baf', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_range_pricing,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(lcl_range_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'range', 0, 'rate')).to eq(11)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_KG_RANGE')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_4,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_4.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        expect(manipulated_pricings.first.dig('flat_margins')).to eq('bas' => 0.1e2)
      end

      it 'returns the manipulated freight pricing attached to the user for addition margin with flat margins' do
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
        margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing_4, tenant: tenants_tenant, applicable: tenants_user, value: 0, operator: '%')
        bas_charge_category = lcl_pricing_4.fees.first.charge_category
        FactoryBot.create(:pricings_detail, margin: margin, value: 10, operator: '+', charge_category: bas_charge_category)

        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_4,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(lcl_pricing_4.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        expect(manipulated_pricings.first.dig('flat_margins')).to eq('bas' => 0.1e2)
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        manipulated_pricings.sort_by! { |m| m['effective_date'] }
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            itinerary_id: group_pricing.itinerary_id,
            tenant_vehicle_id: group_pricing.tenant_vehicle_id,
            cargo_class: group_pricing.cargo_class,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(group_pricing.id)
        expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
        expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :import_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        manipulated_pricings.sort_by! { |m| m['effective_date'] }

        expect(manipulated_pricings.map { |mp| mp['id'] }.uniq).to match_array([local_charge.id])
        expect(manipulated_pricings.map { |mp| mp.dig('fees', 'SOLAS', 'value') }).to match_array([17.5, 19.25, 17.5, 17.5])
        expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to eq([{}, { 'SOLAS' => 0.1e2 }, { 'SOLAS' => 0.1e2 }, {}])
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :import_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        manipulated_pricings.map { |mp| mp.dig('fees', 'PUF', 'value') }
        expect(manipulated_pricings.pluck(:id).uniq).to eq([local_charge.id])
        expect(manipulated_pricings.flat_map { |pricing| pricing['fees'].keys }.uniq).to eq(['SOLAS'])
        expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to eq([{}, { 'SOLAS' => 0.1e2 }, { 'SOLAS' => 0.1e2 }, {}])
        expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'SOLAS', 'value') }).to match_array([17.5, 19.25, 17.5, 17.5])
        expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'SOLAS', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
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
        manipulated_pricings_and_metadata = described_class.new(
          type: :export_margin,
          target: tenants_user,
          tenant: tenants_tenant,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
      end

      it 'returns multiple manipulated local_charges when margins overlap attached to the group without pricing' do
        Timecop.freeze(Time.zone.now) do
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
          manipulated_pricings_and_metadata = described_class.new(
            target: tenants_user,
            tenant: tenants_tenant,
            type: :export_margin,
            args: {
              sandbox: nil,
              local_charge: local_charge,
              schedules: schedules,
              shipment: lcl_shipment,
              without_meta: true
            }
          ).perform
          manipulated_pricings = manipulated_pricings_and_metadata.first

          manipulated_pricings.sort_by! { |m| m['effective_date'] }
          expect(manipulated_pricings.pluck(:id).uniq).to eq([local_charge.id])
          expect(manipulated_pricings.flat_map { |pricing| pricing['fees'].keys }.uniq).to eq(['SOLAS'])
          expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'SOLAS', 'value') }).to eq([19.25, 17.5, 26.25, 17.5])
          expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'SOLAS', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
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
                                           'baf' => {
                                             'key' => 'baf',
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(%w[SOLAS baf])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(19.25)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first.dig('fees', 'baf', 'value')).to eq(25)
        expect(manipulated_pricings.first.dig('fees', 'baf', 'rate_basis')).to eq('PER_SHIPMENT')
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(local_charge.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['SOLAS'])
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'value')).to eq(17.5)
        expect(manipulated_pricings.first.dig('flat_margins')).to eq('SOLAS' => 0.1e2)
        expect(manipulated_pricings.first.dig('fees', 'SOLAS', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to match_array([{ 'SOLAS' => 0.1e2 }])
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :trucking_pre_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(275)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :trucking_pre_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        manipulated_pricings.sort_by! { |m| m['effective_date'] }

        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to match_array([{}, { 'PUF' => 0.5e1, 'trucking_pre' => 0.5e1 }, { 'PUF' => 0.5e1, 'trucking_pre' => 0.5e1 }, {}])
        expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'PUF', 'value') }).to match_array([250.0, 275.0, 250.0, 250.0])
        expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'PUF', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
        expect(manipulated_pricings.map { |pricing| pricing.dig('rates', 'kg', 0, 'rate', 'value') }).to eq([0.2375e3, 0.26125e3, 0.2375e3, 0.2375e3])
      end

      it 'returns the manipulated trucking pricing attached to the group' do
        hub = itinerary_1.first_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, tenant: tenants_tenant, applicable: group_1)
        manipulated_pricings_and_metadata = described_class.new(
          type: :trucking_pre_margin,
          target: tenants_user,
          tenant: tenants_tenant,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(275)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
      end

      it 'returns multiple manipulated trucking pricings when margins overlap attached to the group without pricing' do
        Timecop.freeze(Time.zone.now) do
          hub = itinerary_1.first_stop.hub
          trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

          FactoryBot.create(:trucking_pre_margin,
                            destination_hub: hub,
                            effective_date: Date.today.beginning_of_day,
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
          manipulated_pricings_and_metadata = described_class.new(
            target: tenants_user,
            tenant: tenants_tenant,
            type: :trucking_pre_margin,
            args: {
              sandbox: nil,
              trucking_pricing: trucking_pricing,
              shipment: lcl_shipment,
              date: Date.today + 5.days,
              without_meta: true
            }
          ).perform
          manipulated_pricings = manipulated_pricings_and_metadata.first
          manipulated_pricings.sort_by! { |m| m['effective_date'] }

          expect(manipulated_pricings.map { |tp| tp['id'] }.uniq).to match_array([trucking_pricing.id])
          expect(manipulated_pricings.map { |mp| mp[:rates].dig('kg', 0, 'rate', 'value') }).to match_array([0.26125e3, 0.391875e3, 0.35625e3, 0.2375e3])
          expect(manipulated_pricings.map { |mp| mp.dig('fees', 'PUF', 'value') }).to match_array([0.275e3, 0.4125e3, 0.375e3, 0.25e3])
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
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :trucking_on_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first
        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(275)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
      end

      it 'returns the manipulated trucking pricing with specific detail attached to the user' do
        hub = itinerary_1.last_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'on')
        user_base_margin = FactoryBot.create(:trucking_on_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        FactoryBot.create(:pricings_detail, margin: user_base_margin, value: 0.25, charge_category: puf_charge_category)

        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :trucking_on_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(312.5)
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'rate_basis')).to eq('PER_SHIPMENT')
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
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

        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :trucking_on_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform
        manipulated_pricings = manipulated_pricings_and_metadata.first

        expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
        expect(manipulated_pricings.first['fees'].keys).to eq(['PUF'])
        expect(manipulated_pricings.first.dig('fees', 'PUF', 'value')).to eq(21.875)
        expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
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
        target: tenants_user,
        tenant: tenants_tenant,
        type: :freight_margin,
        args: {
          sandbox: nil,
          pricing: lcl_pricing_user,
          schedules: schedules,
          shipment: lcl_shipment,
          without_meta: true
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
        target: tenants_user,
        tenant: tenants_tenant,
        type: :freight_margin,
        args: {
          sandbox: nil,
          pricing: lcl_pricing_tenant,
          schedules: schedules,
          shipment: lcl_shipment,
          without_meta: true
        }
      ).find_applicable_margins
      expect(margins.first[:margin]).to eq(tenant_margin)
    end
  end

  describe 'fee_keys' do
    it 'returns an empty array when no vairables are present' do
      lcl_pricing = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
      trips = [1, 3].map do |num|
        base_date = num.days.from_now
        FactoryBot.create(:legacy_trip,
                          itinerary: lcl_pricing.itinerary,
                          tenant_vehicle: lcl_pricing.tenant_vehicle,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
      end
      schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }

      keys = described_class.new(
        target: tenants_user,
        tenant: tenants_tenant,
        type: :invalid_type,
        args: {
          sandbox: nil,
          schedules: schedules,
          shipment: lcl_shipment
        }
      ).fee_keys
      expect(keys).to match_array([])
    end
  end

  describe 'type error' do
    it 'rraises an error when there are no schedules and the type is freight margin' do
      args = {
        sandbox: nil,
        schedules: [],
        shipment: lcl_shipment
      }

      expect { described_class.new(target: tenants_user, tenant: tenants_tenant, type: :freight_margin, args: args) }.to raise_error(Pricings::Manipulator::MissingArgument)
    end
  end

  context 'with metadata' do
    describe 'freight margins' do
      it 'returns the manipulated freight pricing with metadata attached to the user - single margin' do
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
        margin = FactoryBot.create(:freight_margin, pricing: lcl_pricing_1, tenant: tenants_tenant, applicable: tenants_user)
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: false
          }
        ).perform

        metadata = manipulated_pricings_and_metadata.second.first

        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
        expect(metadata[:pricing_id]).to eq(lcl_pricing_1.id)
        expect(metadata[:fees].keys).to eq([:bas])
        expect(metadata.dig(:fees, :bas, :breakdowns).length).to eq(2)
        expect(metadata.dig(:fees, :bas, :breakdowns, 1, :margin_id)).to eq(margin.id)
        expect(metadata.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(margin.value)
      end

      it 'returns the manipulated freight pricing with metadata attached to the user - double margin' do
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
        margin_1 = FactoryBot.create(:freight_margin, pricing: lcl_pricing_1, tenant: tenants_tenant, applicable: tenants_user)
        margin_2 = FactoryBot.create(:freight_margin, pricing: lcl_pricing_1, tenant: tenants_tenant, applicable: tenants_user, value: 50, operator: '+')
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: false
          }
        ).perform

        metadata = manipulated_pricings_and_metadata.second.first
        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
        expect(metadata[:pricing_id]).to eq(lcl_pricing_1.id)
        expect(metadata[:fees].keys).to eq([:bas])
        expect(metadata.dig(:fees, :bas, :breakdowns).length).to eq(3)
        expect(metadata.dig(:fees, :bas, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :bas, :breakdowns, 2, :margin_id)).to eq(margin_2.id)
        expect(metadata.dig(:fees, :bas, :breakdowns, 2, :margin_value)).to eq(margin_2.value)
      end

      it 'returns the manipulated freight pricing with metadata attached to the user - flat margin, many fees' do
        lcl_pricing_1 = FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1)
        baf_fee = FactoryBot.create(:pricings_fee, pricing: lcl_pricing_1, charge_category: FactoryBot.create(:baf_charge))
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
        margin_1 = FactoryBot.create(:freight_margin, pricing: lcl_pricing_1, tenant: tenants_tenant, applicable: tenants_user)
        margin_2 = FactoryBot.create(:freight_margin, pricing: lcl_pricing_1, tenant: tenants_tenant, applicable: tenants_user, value: 50, operator: '+')
        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :freight_margin,
          args: {
            sandbox: nil,
            pricing: lcl_pricing_1,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: false
          }
        ).perform

        metadata = manipulated_pricings_and_metadata.second.first

        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
        expect(metadata[:pricing_id]).to eq(lcl_pricing_1.id)
        expect(metadata[:fees].keys).to match_array(%i[bas baf])
        expect(metadata.dig(:fees, :bas, :breakdowns).length).to eq(3)
        expect(metadata.dig(:fees, :bas, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :bas, :breakdowns, 2, :margin_id)).to eq(margin_2.id)
        expect(metadata.dig(:fees, :bas, :breakdowns, 2, :margin_value)).to eq(margin_2.value / 2)
        expect(metadata.dig(:fees, :baf, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :baf, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :baf, :breakdowns, 2, :margin_id)).to eq(margin_2.id)
        expect(metadata.dig(:fees, :baf, :breakdowns, 2, :margin_value)).to eq(margin_2.value / 2)
      end
    end
    describe 'local charge margins' do
      let(:hub) { itinerary_1.first_stop.hub }
      it 'returns the manipulated local charge with metadata attached to the user - single margin' do
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)

        margin = FactoryBot.create(:export_margin,
                                   origin_hub: hub,
                                   tenant_vehicle: tenant_vehicle_1,
                                   tenant: tenants_tenant,
                                   applicable: tenants_user)

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

        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: false
          }
        ).perform

        metadata = manipulated_pricings_and_metadata.second.first

        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
        expect(metadata[:pricing_id]).to eq(local_charge.id)
        expect(metadata[:fees].keys).to eq([:SOLAS])
        expect(metadata.dig(:fees, :SOLAS, :breakdowns).length).to eq(2)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 1, :margin_id)).to eq(margin.id)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 1, :margin_value)).to eq(margin.value)
      end

      it 'returns the manipulated local charge with metadata attached to the user - double margin' do
        local_charge = FactoryBot.create(:legacy_local_charge,
                                         hub: hub,
                                         direction: 'export',
                                         tenant_vehicle: tenant_vehicle_1,
                                         tenant: tenant)

        margin_1 = FactoryBot.create(:export_margin,
                                     origin_hub: hub,
                                     tenant_vehicle: tenant_vehicle_1,
                                     tenant: tenants_tenant,
                                     applicable: tenants_user)
        margin_2 = FactoryBot.create(:export_margin,
                                     origin_hub: hub,
                                     tenant_vehicle: tenant_vehicle_1,
                                     tenant: tenants_tenant,
                                     applicable: tenants_user,
                                     value: 50,
                                     operator: '+')

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

        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: false
          }
        ).perform

        metadata = manipulated_pricings_and_metadata.second.first
        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
        expect(metadata[:pricing_id]).to eq(local_charge.id)
        expect(metadata[:fees].keys).to eq([:SOLAS])
        expect(metadata.dig(:fees, :SOLAS, :breakdowns).length).to eq(3)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 2, :margin_id)).to eq(margin_2.id)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 2, :margin_value)).to eq(margin_2.value)
      end

      it 'returns the manipulated local charge with metadata attached to the user - flat margin, many fees' do
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
                                           'THC' => {
                                             'key' => 'THC',
                                             'max' => nil,
                                             'min' => 15,
                                             'name' => 'THC',
                                             'value' => 15,
                                             'currency' => 'EUR',
                                             'rate_basis' => 'PER_WM'
                                           }
                                         })

        margin_1 = FactoryBot.create(:export_margin,
                                     origin_hub: hub,
                                     tenant_vehicle: tenant_vehicle_1,
                                     tenant: tenants_tenant,
                                     applicable: tenants_user)
        margin_2 = FactoryBot.create(:export_margin,
                                     origin_hub: hub,
                                     tenant_vehicle: tenant_vehicle_1,
                                     tenant: tenants_tenant,
                                     applicable: tenants_user,
                                     value: 50,
                                     operator: '+')

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

        manipulated_pricings_and_metadata = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :export_margin,
          args: {
            sandbox: nil,
            local_charge: local_charge,
            schedules: schedules,
            shipment: lcl_shipment,
            without_meta: false
          }
        ).perform

        metadata = manipulated_pricings_and_metadata.second.first
        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
        expect(metadata[:pricing_id]).to eq(local_charge.id)
        expect(metadata[:fees].keys).to eq(%i[SOLAS THC])
        expect(metadata.dig(:fees, :SOLAS, :breakdowns).length).to eq(3)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 2, :margin_id)).to eq(margin_2.id)
        expect(metadata.dig(:fees, :SOLAS, :breakdowns, 2, :margin_value)).to eq(margin_2.value / 2)
        expect(metadata.dig(:fees, :THC, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :THC, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :THC, :breakdowns, 2, :margin_id)).to eq(margin_2.id)
        expect(metadata.dig(:fees, :THC, :breakdowns, 2, :margin_value)).to eq(margin_2.value / 2)
      end
    end

    describe 'trucking pricings' do
      it 'returns the manipulated trucking pricing attached to the user' do
        hub = itinerary_1.first_stop.hub
        trucking_pricing = FactoryBot.create(:trucking_trucking, hub: hub, tenant: tenant, carriage: 'pre')

        margin_1 = FactoryBot.create(:trucking_pre_margin, destination_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
        manipulated_pricings, metadata_results = described_class.new(
          target: tenants_user,
          tenant: tenants_tenant,
          type: :trucking_pre_margin,
          args: {
            sandbox: nil,
            trucking_pricing: trucking_pricing,
            shipment: lcl_shipment,
            date: Date.today + 5.days,
            without_meta: true
          }
        ).perform

        metadata = metadata_results.first

        expect(metadata.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
        expect(metadata[:pricing_id]).to eq(trucking_pricing.id)
        expect(metadata[:fees].keys).to eq(%i[PUF trucking_lcl])
        expect(metadata.dig(:fees, :PUF, :breakdowns).length).to eq(2)
        expect(metadata.dig(:fees, :trucking_lcl, :breakdowns).length).to eq(2)
        expect(metadata.dig(:fees, :PUF, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :PUF, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
        expect(metadata.dig(:fees, :trucking_lcl, :breakdowns, 1, :margin_id)).to eq(margin_1.id)
        expect(metadata.dig(:fees, :trucking_lcl, :breakdowns, 1, :margin_value)).to eq(margin_1.value)
      end
    end
  end
end
