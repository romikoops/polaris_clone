# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Manipulator do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle]) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:tenants_user) do
    Tenants::User.find_by(legacy_id: user.id).tap do |tapped_user|
      tapped_user.company = FactoryBot.create(:tenants_company)
    end
  end
  let(:group) do
    FactoryBot.create(:tenants_group, tenant: tenants_tenant).tap do |group|
      FactoryBot.create(:tenants_membership, member: tenants_user, group: group)
    end
  end
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:itinerary) { FactoryBot.create(:default_itinerary, tenant: tenant) }
  let(:trips) do
    [1, 3, 5, 7, 11, 12].map do |num|
      base_date = num.days.from_now
      FactoryBot.create(:legacy_trip,
                        itinerary: itinerary,
                        tenant_vehicle: tenant_vehicle,
                        closing_date: base_date - 4.days,
                        start_date: base_date,
                        end_date: base_date + 30.days)
    end
  end
  let(:schedules) { trips.map { |t| Legacy::Schedule.from_trip(t) } }
  let(:puf_charge_category) { FactoryBot.create(:puf_charge, tenant: tenant) }
  let(:solas_charge_category) { FactoryBot.create(:solas_charge, tenant: tenant) }
  let(:bas_charge_category) { Legacy::ChargeCategory.find_by(code: 'bas') || FactoryBot.create(:bas_charge, tenant: tenant) }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, tenant: tenant) }

  let(:args) do
    {
      sandbox: nil,
      pricing: pricing,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count,
      without_meta: true
    }
  end
  let(:attribute_args) do
    {
      sandbox: nil,
      itinerary_id: pricing.itinerary_id,
      tenant_vehicle_id: pricing.tenant_vehicle_id,
      cargo_class: pricing.cargo_class,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count,
      without_meta: true
    }
  end
  let(:klass) do
    described_class.new(
      target: tenants_user,
      tenant: tenants_tenant,
      type: :freight_margin,
      args: args
    )
  end

  let(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, tenant: tenant) }
  let(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, tenant_vehicle: tenant_vehicle, tenant: tenant) }
  let(:target_shipment) { lcl_shipment }
  let(:hub) { itinerary.hubs.first }

  before do
    FactoryBot.create(:profiles_profile, user_id: tenants_user.id)
    FactoryBot.create(:tenants_scope, content: { base_pricing: true }, target: tenants_tenant)
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

  describe '.perform' do
    context 'with freight pricings and user margin' do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user)
      end

      it 'returns the manipulated freight pricing attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with freight pricings and user margin (total)' do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, operator: '+', value: 100)
      end

      it 'returns the manipulated freight pricing attached to the user (single total margin)' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
          expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to eq([{ 'bas' => 100 }])
        end
      end
    end

    context 'with freight pricings and user margin (absolute)' do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, operator: '%', value: 0).tap do |tapped_margin|
          FactoryBot.create(:bas_margin_detail, margin: tapped_margin, value: 50, operator: '&', charge_category: bas_charge_category)
        end
      end

      it 'returns the manipulated freight pricing attached to the user (single absolute margin)' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(75)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
          expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to eq([{}])
        end
      end
    end

    context 'with freight pricings and multiple user margin' do
      before do
        FactoryBot.create(:freight_margin,
                          pricing: pricing,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:freight_margin,
                          itinerary_id: pricing.itinerary_id,
                          tenant: tenants_tenant,
                          applicable: group,
                          value: 0,
                          operator: '%',
                          application_order: 2,
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 30.days).end_of_day).tap do |tapped_margin|
          FactoryBot.create(:bas_margin_detail, margin: tapped_margin, value: 25, operator: '&', charge_category: bas_charge_category)
        end
      end

      it 'returns the manipulated freight pricing attached to the user with multiple margins' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.pluck(:id).uniq).to eq([pricing.id])
          expect(manipulated_pricings.flat_map { |result| result['data'].keys }.uniq).to match_array(['bas'])
          expect(manipulated_pricings.map { |result| result.dig('data', 'bas', 'rate') }).to match_array([25.0, 52.5, 50.0, 25.0])
          expect(manipulated_pricings.map { |result| result.dig('data', 'bas', 'rate_basis') }.uniq).to match_array(['PER_WM'])
        end
      end
    end

    context 'with freight pricings and multiple user margins (relative and absolute)' do
      before do
        FactoryBot.create(:freight_margin,
                          pricing: pricing,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:freight_margin,
                          itinerary_id: pricing.itinerary_id,
                          tenant: tenants_tenant,
                          applicable: group,
                          value: 0,
                          operator: '%',
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 30.days).end_of_day).tap do |tapped_margin|
                            FactoryBot.create(:bas_margin_detail, margin: tapped_margin, value: 25, operator: '&', charge_category: bas_charge_category)
                          end
      end

      it 'returns the manipulated freight pricing attached to the user with multiple margins' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.pluck(:id).uniq).to eq([pricing.id])
          expect(manipulated_pricings.flat_map { |result| result['data'].keys }.uniq).to match_array(['bas'])
          expect(manipulated_pricings.map { |result| result.dig('data', 'bas', 'rate') }).to match_array([25.0, 52.5, 50, 25.0])
          expect(manipulated_pricings.map { |result| result.dig('data', 'bas', 'rate_basis') }.uniq).to match_array(['PER_WM'])
        end
      end
    end

    context 'with freight pricings and group margin' do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: group)
      end

      it 'returns the manipulated freight pricing attached to the group' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with freight pricings, group margin, identified by attributes' do
      before do
        FactoryBot.create(:freight_margin,
                          itinerary_id: pricing.itinerary_id,
                          tenant_vehicle_id: pricing.tenant_vehicle_id,
                          cargo_class: pricing.cargo_class,
                          tenant: tenants_tenant,
                          applicable: group)
      end

      let(:args) { attribute_args }

      it 'returns the manipulated freight pricing attached to the group without pricing' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with multiple manipulated freight pricings when margins overlap attached to the group without pricing' do
      Timecop.freeze(Time.zone.now) do
        let!(:margin_a) do
          FactoryBot.create(:freight_margin, pricing: pricing, effective_date: Time.zone.today - 3.days, expiration_date: (Time.zone.today + 10.days).end_of_day, tenant: tenants_tenant, applicable: group)
        end
        let!(:margin_b) do
          FactoryBot.create(:freight_margin,
                            pricing: pricing,
                            effective_date: Time.zone.today + 8.days,
                            expiration_date: (Time.zone.today + 22.days).end_of_day,
                            tenant: tenants_tenant,
                            value: 0.5,
                            applicable: group)
        end
        let(:args) do
          {
            sandbox: nil,
            itinerary_id: pricing.itinerary_id,
            tenant_vehicle_id: pricing.tenant_vehicle_id,
            cargo_class: pricing.cargo_class,
            schedules: schedules,
            shipment: target_shipment,
            without_meta: true
          }
        end

        let!(:results) { klass.perform.first.sort_by! { |m| m['effective_date'] } }

        it 'returns the correct data for the first period' do
          aggregate_failures do
            expect(results[0]['id']).to eq(pricing.id)
            expect(results[0]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
            expect(results.dig(0, 'data').keys).to eq(['bas'])
            expect(results.dig(0, 'data', 'bas', 'rate')).to eq(27.5)
            expect(results.dig(0, 'data', 'bas', 'rate_basis')).to eq('PER_WM')
          end
        end

        it 'returns the correct data for the middle period' do
          aggregate_failures do
            expect(results[1]['id']).to eq(pricing.id)
            expect(results[1]['effective_date']).to eq(margin_b.effective_date)
            expect(results[1]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
            expect(results.dig(1, 'data').keys).to eq(['bas'])
            expect(results.dig(1, 'data', 'bas', 'rate')).to eq(41.25)
            expect(results.dig(1, 'data', 'bas', 'rate_basis')).to eq('PER_WM')
          end
        end

        it 'returns the correct data for the last period' do
          aggregate_failures do
            expect(results[2]['id']).to eq(pricing.id)
            expect(results[2]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
            expect(results[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)
            expect(results.dig(2, 'data').keys).to eq(['bas'])
            expect(results.dig(2, 'data', 'bas', 'rate')).to eq(37.5)
            expect(results.dig(2, 'data', 'bas', 'rate_basis')).to eq('PER_WM')
          end
        end
      end
    end

    context 'with freight pricings and group through the company margin' do
      before do
        FactoryBot.create(:tenants_group, tenant: tenants_tenant).tap do |company_group|
          FactoryBot.create(:tenants_membership, member: tenants_user.company, group: company_group)
          FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: company_group)
        end
      end

      it 'returns the manipulated freight pricing attached to the group via company' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing with specific detail attached to the user' do
      let(:pricing) do
        FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle).tap do |tapped_pricing|
          FactoryBot.create(:fee_per_wm, tenant: tenant, charge_category: bas_charge_category, pricing: tapped_pricing, rate: 40)
          FactoryBot.create(:freight_margin, pricing: tapped_pricing, tenant: tenants_tenant, applicable: tenants_user).tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail, margin: tapped_margin, value: 0.25, charge_category: bas_charge_category)
          end
        end
      end

      it 'returns the manipulated freight pricing with specific detail attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(50)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing with one specific detail and general attached to the user' do
      let(:pricing) do
        FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle).tap do |tapped_pricing|
          FactoryBot.create(:fee_per_wm, tenant: tenant, charge_category: bas_charge_category, pricing: tapped_pricing, rate: 40)
          FactoryBot.create(:fee_per_wm, tenant: tenant, charge_category: baf_charge_category, pricing: tapped_pricing, rate: 40)
          FactoryBot.create(:freight_margin, pricing: tapped_pricing, tenant: tenants_tenant, applicable: tenants_user).tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail, margin: tapped_margin, value: 0.25, charge_category: bas_charge_category)
          end
        end
      end
      let(:manipulated_pricings) { klass.perform.first }

      it 'returns the manipulated freight pricing with one specific detail and general attached to the user' do
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to match_array(%w[bas baf])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(50)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
          expect(manipulated_pricings.first.dig('data', 'baf', 'rate')).to eq(44)
          expect(manipulated_pricings.first.dig('data', 'baf', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing attached to the user with a range' do
      let(:pricing) do
        FactoryBot.create(:lcl_range_pricing, tenant_vehicle: tenant_vehicle).tap do |tapped_pricing|
          FactoryBot.create(:freight_margin, pricing: tapped_pricing, tenant: tenants_tenant, applicable: tenants_user, value: 0, operator: '%').tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail, margin: tapped_margin, value: 0.25, charge_category: bas_charge_category)
          end
        end
      end

      it 'returns the manipulated freight pricing attached to the user with a range' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'range', 0, 'rate')).to eq(12.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_KG_RANGE')
        end
      end
    end

    context 'with manipulated freight pricing attached to the user for total margin' do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, value: 10, operator: '+')
      end

      it 'returns the manipulated freight pricing attached to the user for total margin' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
          expect(manipulated_pricings.first.dig('flat_margins')).to eq('bas' => 0.1e2)
        end
      end
    end

    context 'with manipulated freight pricing attached to the user for total margin with specific margin detail' do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, value: 10, operator: '+').tap do |tapped_margin|
          FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 10, operator: '+', charge_category: bas_charge_category)
        end
      end

      let(:charge_category) { pricing.fees.first.charge_category }

      it 'returns the manipulated freight pricing attached to the user for addition margin with total margins' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
          expect(manipulated_pricings.first.dig('flat_margins')).to eq('bas' => 0.1e2)
        end
      end
    end

    context 'with manipulated freight pricing attached to the tenant without pricing' do
      before do
        FactoryBot.create(:freight_margin,
                          itinerary_id: pricing.itinerary_id,
                          tenant_vehicle_id: pricing.tenant_vehicle_id,
                          cargo_class: pricing.cargo_class,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
      end

      let(:args) { attribute_args }

      it 'returns the manipulated freight pricing attached to the tenant without pricing' do
        manipulated_pricings, _metadata = klass.perform
        manipulated_pricings.sort_by! { |m| m['effective_date'] }
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing attached to the tenant with itinerary only' do
      before do
        FactoryBot.create(:freight_margin,
                          itinerary_id: pricing.itinerary_id,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
      end

      let(:args) { attribute_args }

      it 'returns the manipulated freight pricing attached to the tenant with itinerary only' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing attached to the tenant with default_for' do
      let(:args) { attribute_args }

      it 'returns the manipulated freight pricing attached to the tenant with default_for' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(25)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing attached to the tenant with nothing else' do
      before do
        FactoryBot.create(:freight_margin, tenant: tenants_tenant, applicable: tenants_tenant)
      end

      let(:args) { attribute_args }

      it 'returns the manipulated freight pricing attached to the tenant with nothing else' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing attached to hub and cargo class' do
      before do
        FactoryBot.create(:freight_margin,
                          tenant: tenants_tenant,
                          origin_hub: pricing.itinerary.hubs.first,
                          cargo_class: pricing.cargo_class,
                          applicable: tenants_tenant)
      end

      let(:args) { attribute_args }

      it 'returns the manipulated freight pricing attached to hub and cargo class' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(pricing.id)
          expect(manipulated_pricings.first['data'].keys).to eq(['bas'])
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate')).to eq(27.5)
          expect(manipulated_pricings.first.dig('data', 'bas', 'rate_basis')).to eq('PER_WM')
        end
      end
    end

    context 'with manipulated freight pricing with metadata attached to the user - single margin' do
      let!(:margin) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user) }
      let!(:metadata) { klass.perform.second }
      let!(:metadatum) { metadata.first }

      it 'returns the manipulated freight pricing with metadata attached to the user - single margin' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
          expect(metadatum[:pricing_id]).to eq(pricing.id)
          expect(metadatum[:fees].keys).to eq([:bas])
          expect(metadatum.dig(:fees, :bas, :breakdowns).length).to eq(2)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :source_id)).to eq(margin.id)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(margin.value)
        end
      end
    end

    context 'with manipulated freight pricing with metadata attached to the user - single absolute margin' do
      let(:parent_margin) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, operator: '%', value: 0) }
      let!(:detail) { FactoryBot.create(:bas_margin_detail, margin: parent_margin, value: 50, operator: '&', charge_category: bas_charge_category) }

      let!(:metadata) { klass.perform.second }
      let!(:metadatum) { metadata.first }

      it 'returns the manipulated freight pricing with metadata attached to the user - single absolute margin' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
          expect(metadatum[:pricing_id]).to eq(pricing.id)
          expect(metadatum[:fees].keys).to eq([:bas])
          expect(metadatum.dig(:fees, :bas, :breakdowns).length).to eq(2)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :source_id)).to eq(detail.id)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(detail.value)
        end
      end
    end

    context 'with manipulated freight pricing with metadata attached to the user - double margin' do
      let!(:margin1) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user) }
      let!(:margin2) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, value: 50, operator: '+') }
      let!(:metadata) { klass.perform.second }
      let(:metadatum) { metadata.first }

      it 'returns the manipulated freight pricing with metadata attached to the user - general info' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
          expect(metadatum[:pricing_id]).to eq(pricing.id)
          expect(metadatum[:fees].keys).to eq([:bas])
        end
      end

      it 'returns the manipulated freight pricing with metadata attached to the user - first margin' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :bas, :breakdowns).length).to eq(3)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(margin1.value)
        end
      end

      it 'returns the manipulated freight pricing with metadata attached to the user - second margin' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :bas, :breakdowns).length).to eq(3)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 2, :source_id)).to eq(margin2.id)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 2, :margin_value)).to eq(margin2.value)
        end
      end
    end

    context 'with manipulated freight pricing and no fees' do
      before do
        pricing.fees.destroy_all
      end

      it 'returns a blank array if the pricing has no fees' do
        expect(klass.perform.first).to eq([])
      end
    end

    context 'with manipulated freight pricing with metadata attached to the user - flat margin, many fees' do
      let(:pricing) do
        FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle).tap do |tapped_pricing|
          FactoryBot.create(:pricings_fee, pricing: tapped_pricing, charge_category: FactoryBot.create(:baf_charge))
        end
      end
      let!(:margin1) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user) }
      let!(:margin2) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user, value: 50, operator: '+') }
      let!(:metadata) { klass.perform.second }
      let(:metadatum) { metadata.first }

      it 'returns the manipulated freight pricing with metadata attached to the user - flat margin, general info' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id])
          expect(metadatum[:pricing_id]).to eq(pricing.id)
          expect(metadatum[:fees].keys).to match_array(%i[bas baf])
          expect(metadatum.dig(:fees, :bas, :breakdowns).length).to eq(3)
        end
      end

      it 'returns the manipulated freight pricing with metadata attached to the user - flat margin, first fee' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 1, :margin_value)).to eq(margin1.value)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 2, :source_id)).to eq(margin2.id)
          expect(metadatum.dig(:fees, :bas, :breakdowns, 2, :margin_value)).to eq(margin2.value / 2)
        end
      end

      it 'returns the manipulated freight pricing with metadata attached to the user - flat margin, second fee' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :baf, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :baf, :breakdowns, 1, :margin_value)).to eq(margin1.value)
          expect(metadatum.dig(:fees, :baf, :breakdowns, 2, :source_id)).to eq(margin2.id)
          expect(metadatum.dig(:fees, :baf, :breakdowns, 2, :margin_value)).to eq(margin2.value / 2)
        end
      end
    end
  end
end
