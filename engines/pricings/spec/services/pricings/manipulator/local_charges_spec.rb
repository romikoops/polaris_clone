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

  let!(:solas_charge_category) { FactoryBot.create(:solas_charge, tenant: tenant) }
  let(:bas_charge_category) { FactoryBot.create(:bas_charge, tenant: tenant) }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, tenant: tenant) }
  let(:margin_type) { :export_margin }
  let(:args) do
    {
      sandbox: nil,
      local_charge: local_charge,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count,
      without_meta: true
    }
  end
  let(:klass) do
    described_class.new(
      target: tenants_user,
      tenant: tenants_tenant,
      type: margin_type,
      args: args
    )
  end
  let(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, tenant: tenant) }
  let(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, tenant_vehicle: tenant_vehicle, tenant: tenant) }
  let(:target_shipment) { lcl_shipment }
  let(:hub) { itinerary.hubs.first }

  before do
    FactoryBot.create(:profiles_profile, user_id: tenants_user.id)
    FactoryBot.create(:tenants_scope, content: {}, target: tenants_tenant)
    FactoryBot.create(:thc_charge, tenant: tenant)
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
    context 'with manipulated local_charge (export) attached to the user' do
      before do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user)
      end

      it 'returns the manipulated local_charge (export) attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local_charge (export) attached to the user not covering entire validity' do
      before do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          effective_date: local_charge.effective_date + 10.days,
                          expiration_date: local_charge.effective_date + 20.days,
                          applicable: tenants_user)
      end

      let!(:results) { klass.perform.first.sort_by! { |m| m['effective_date'] } }

      it 'returns the manipulated local_charge first charge' do
        aggregate_failures do
          expect(results.first['id']).to eq(local_charge.id)
          expect(results.first['fees'].keys).to eq(['solas'])
          expect(results.first.dig('fees', 'solas', 'value')).to eq(17.5)
          expect(results.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end

      it 'returns the manipulated local_charge last charge' do
        aggregate_failures do
          expect(results.last['id']).to eq(local_charge.id)
          expect(results.last['fees'].keys).to eq(['solas'])
          expect(results.last.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(results.last.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local_charge (import) attached to the user' do
      before do
        FactoryBot.create(:import_margin,
                          destination_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user)
      end

      let(:margin_type) { :import_margin }
      let(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, direction: 'import', tenant_vehicle: tenant_vehicle, tenant: tenant) }

      it 'returns the manipulated local_charge (import) attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local_charge (export) attached to the user with multiple margins' do
      let!(:margin_a) do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 10.days).end_of_day)
      end
      let!(:margin_b) do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: group,
                          value: 10,
                          operator: '+',
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end
      let!(:results) { klass.perform.first.sort_by! { |m| m['effective_date'] } }

      it 'returns the manipulated local_charge (export) attached to the user with multiple margins' do
        aggregate_failures do
          expect(results.map { |mp| mp['id'] }.uniq).to match_array([local_charge.id])
          expect(results.map { |mp| mp.dig('fees', 'solas', 'value') }).to match_array([17.5, 19.25, 17.5, 17.5])
          expect(results.map { |pricing| pricing.dig('flat_margins') }).to eq([{}, { 'solas' => 0.1e2 }, { 'solas' => 0.1e2 }, {}])
        end
      end

      it 'returns the manipulated local_charge with the correct dates' do
        aggregate_failures do
          expect(results[0]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
          expect(results[1]['effective_date']).to eq(margin_b.effective_date)
          expect(results[1]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
          expect(results[2]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
          expect(results[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)
        end
      end
    end

    context 'with manipulated local_charge (import) attached to the user with multiple margins' do
      before do
        FactoryBot.create(:import_margin,
                          destination_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:import_margin,
                          destination_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: group,
                          value: 10,
                          operator: '+',
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end

      let(:margin_type) { :import_margin }
      let(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, direction: 'import', tenant_vehicle: tenant_vehicle, tenant: tenant) }

      it 'returns the manipulated local_charge (import) attached to the user with multiple margins' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.pluck(:id).uniq).to eq([local_charge.id])
          expect(manipulated_pricings.flat_map { |pricing| pricing['fees'].keys }.uniq).to eq(['solas'])
          expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to eq([{}, { 'solas' => 0.1e2 }, { 'solas' => 0.1e2 }, {}])
          expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'solas', 'value') }).to match_array([17.5, 19.25, 17.5, 17.5])
          expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'solas', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
        end
      end
    end

    context 'with manipulated local_charge attached to the group' do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: group)
      end

      it 'returns the manipulated local_charge attached to the group' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with multiple manipulated local_charges when margins overlap attached to the group' do
      Timecop.freeze(Time.zone.now) do
        let!(:margin_a) do
          FactoryBot.create(:export_margin,
                            origin_hub: hub,
                            tenant_vehicle: tenant_vehicle,
                            effective_date: (Time.zone.today - 3.days).beginning_of_day,
                            expiration_date: (Time.zone.today + 2.days).end_of_day,
                            tenant: tenants_tenant,
                            applicable: group)
        end
        let!(:margin_b) do
          FactoryBot.create(:export_margin,
                            origin_hub: hub,
                            tenant_vehicle: tenant_vehicle,
                            effective_date: (Time.zone.today + 8.days).beginning_of_day,
                            expiration_date: (Time.zone.today + 22.days).end_of_day,
                            tenant: tenants_tenant,
                            value: 0.5,
                            applicable: group)
        end
        let!(:results) { klass.perform.first.sort_by! { |m| m['effective_date'] } }

        it 'returns multiple manipulated local_charges when margins overlap attached to the group' do
          aggregate_failures do
            expect(results.pluck(:id).uniq).to eq([local_charge.id])
            expect(results.flat_map { |pricing| pricing['fees'].keys }.uniq).to eq(['solas'])
            expect(results.map { |pricing| pricing.dig('fees', 'solas', 'value') }).to eq([19.25, 17.5, 26.25, 17.5])
            expect(results.map { |pricing| pricing.dig('fees', 'solas', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
          end
        end

        it 'returns multiple manipulated local_charges with the correct dates' do
          aggregate_failures do
            expect(results[0]['expiration_date'].end_of_minute).to eq(margin_a.expiration_date)
            expect(results[1]['effective_date']).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
            expect(results[1]['expiration_date'].end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
            expect(results[2]['effective_date']).to eq(margin_b.effective_date)
            expect(results[2]['expiration_date'].end_of_minute).to eq(margin_b.expiration_date)
          end
        end
      end
    end

    context 'with manipulated local_charge attached to the group via company' do
      before do
        FactoryBot.create(:tenants_group, tenant: tenants_tenant).tap do |company_group|
          FactoryBot.create(:tenants_membership, member: tenants_user.company, group: company_group)
          FactoryBot.create(:export_margin, origin_hub: hub, tenant_vehicle: tenant_vehicle, tenant: tenants_tenant, applicable: company_group)
        end
      end

      it 'returns the manipulated local_charge attached to the group via company' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local_charge with specific detail attached to the user' do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user, value: 0).tap do |tapped_margin|
          FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: solas_charge_category)
        end
      end

      it 'returns the manipulated local_charge with specific detail attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'value')).to eq(21.875)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local_charge with one specific detail and general attached to the user' do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user).tap do |tapped_margin|
          FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: baf_charge_category)
        end
      end

      let(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
                          hub: hub,
                          direction: 'export',
                          tenant_vehicle: tenant_vehicle,
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
      end
      let!(:results) { klass.perform.first }

      it 'returns the manipulated local_charge with one specific detail and general attached to the user' do
        aggregate_failures do
          expect(results.first['id']).to eq(local_charge.id)
          expect(results.first['fees'].keys).to eq(%w[solas baf])
        end
      end

      it 'returns the manipulated solas fee' do
        aggregate_failures do
          expect(results.first.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(results.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end

      it 'returns the manipulated baf fee' do
        aggregate_failures do
          expect(results.first.dig('fees', 'baf', 'value')).to eq(25)
          expect(results.first.dig('fees', 'baf', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local_charge attached to the user with a range' do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user)
      end

      let(:fees) do
        {
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
        }
      end
      let(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, direction: 'export', fees: fees, tenant_vehicle: tenant_vehicle, tenant: tenant) }

      it 'returns the manipulated local_charge attached to the user with a range' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'range', 0, 'cbm')).to eq(11)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'range', 0, 'ton')).to eq(44)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_CBM_TON_RANGE')
        end
      end
    end

    context 'with manipulated local_charge attached to the user for addition margin' do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, tenant: tenants_tenant, applicable: tenants_user, value: 10, operator: '+')
      end

      let!(:results) { klass.perform.first }

      it 'returns the manipulated local_charge attached to the user for addition margin' do
        aggregate_failures do
          expect(results.first['id']).to eq(local_charge.id)
          expect(results.first['fees'].keys).to eq(['solas'])
          expect(results.first.dig('fees', 'solas', 'value')).to eq(17.5)
          expect(results.first.dig('flat_margins')).to eq('solas' => 0.1e2)
          expect(results.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
          expect(results.map { |pricing| pricing.dig('flat_margins') }).to match_array([{ 'solas' => 0.1e2 }])
        end
      end
    end

    context 'with manipulated local_charge attached to the tenant with nothing else' do
      before do
        FactoryBot.create(:export_margin, tenant: tenants_tenant, applicable: tenants_tenant)
      end

      it 'returns the manipulated local_charge attached to the tenant with nothing else' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(local_charge.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['solas'])
          expect(manipulated_pricings.first.dig('fees', 'solas', 'value')).to eq(19.25)
          expect(manipulated_pricings.first.dig('fees', 'solas', 'rate_basis')).to eq('PER_SHIPMENT')
        end
      end
    end

    context 'with manipulated local charge with metadata attached to the user - single margin' do
      before do
        FactoryBot.create(:export_margin, tenant: tenants_tenant, applicable: tenants_tenant)
      end

      let!(:margin) { FactoryBot.create(:export_margin, origin_hub: hub, tenant_vehicle: tenant_vehicle, tenant: tenants_tenant, applicable: tenants_user) }
      let(:metadata) { klass.perform.second }
      let(:metadatum) { metadata.first }

      it 'returns the manipulated local charge with metadata attached to the user - general info' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
          expect(metadatum[:pricing_id]).to eq(local_charge.id)
          expect(metadatum[:fees].keys).to eq([:solas])
          expect(metadatum.dig(:fees, :solas, :breakdowns).length).to eq(2)
        end
      end

      it 'returns the manipulated local charge with metadata attached to the user - single margin' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :solas, :breakdowns, 1, :source_id)).to eq(margin.id)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 1, :margin_value)).to eq(margin.value)
        end
      end
    end

    context 'with manipulated local charge with metadata attached to the user - double margin' do
      let!(:margin1) do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user)
      end
      let!(:margin2) do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          value: 50,
                          operator: '+')
      end
      let(:metadata) { klass.perform.second }
      let(:metadatum) { metadata.first }

      it 'returns the manipulated local charge with metadata attached to the user - general info' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
          expect(metadatum[:pricing_id]).to eq(local_charge.id)
          expect(metadatum[:fees].keys).to eq([:solas])
          expect(metadatum.dig(:fees, :solas, :breakdowns).length).to eq(3)
        end
      end

      it 'returns the manipulated local charge with metadata attached to the user - first margin' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :solas, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 1, :margin_value)).to eq(margin1.value)
        end
      end

      it 'returns the manipulated local charge with metadata attached to the user - second margin' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :solas, :breakdowns, 2, :source_id)).to eq(margin2.id)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 2, :margin_value)).to eq(margin2.value)
        end
      end
    end

    context 'with manipulated local charge with metadata attached to the user - flat margin, many fees' do
      let(:fees) do
        {
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
        }
      end
      let(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
                          hub: hub,
                          direction: 'export',
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenant,
                          fees: fees)
      end

      let!(:margin1) do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user)
      end
      let!(:margin2) do
        FactoryBot.create(:export_margin,
                          origin_hub: hub,
                          tenant_vehicle: tenant_vehicle,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          value: 50,
                          operator: '+')
      end
      let(:metadata) { klass.perform.second }
      let(:metadatum) { metadata.first }

      it 'returns the manipulated local charge with metadata attached to the user - general info' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
          expect(metadatum[:pricing_id]).to eq(local_charge.id)
          expect(metadatum[:fees].keys).to eq(%i[solas thc])
          expect(metadatum.dig(:fees, :solas, :breakdowns).length).to eq(3)
        end
      end

      it 'returns the manipulated local charge with metadata attached to the user - first fee' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :solas, :breakdowns).length).to eq(3)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 1, :margin_value)).to eq(margin1.value)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 2, :source_id)).to eq(margin2.id)
          expect(metadatum.dig(:fees, :solas, :breakdowns, 2, :margin_value)).to eq(margin2.value / 2)
        end
      end

      it 'returns the manipulated local charge with metadata attached to the user - second fee' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :thc, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :thc, :breakdowns, 1, :margin_value)).to eq(margin1.value)
          expect(metadatum.dig(:fees, :thc, :breakdowns, 2, :source_id)).to eq(margin2.id)
          expect(metadatum.dig(:fees, :thc, :breakdowns, 2, :margin_value)).to eq(margin2.value / 2)
        end
      end
    end
  end
end
