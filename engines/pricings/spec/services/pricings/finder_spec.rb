# frozen_string_literal: true

require 'rails_helper'
require 'timecop'

RSpec.describe Pricings::Finder do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:scope) { FactoryBot.create(:tenants_scope, content: {}, target: tenants_tenant) }
  let(:vehicle) do
    FactoryBot.create(:vehicle,
                      tenant_vehicles: [tenant_vehicle_1])
  end
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express', tenant: tenant) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_20_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_hq_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:agg_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:lcl_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id) }
  let(:fcl_20_pricing) { FactoryBot.create(:fcl_20_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:fcl_20_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_pricing) { FactoryBot.create(:fcl_40_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:fcl_40_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_hq_pricing) { FactoryBot.create(:fcl_40_hq_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:fcl_40_hq_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40_hq', shipment_id: fcl_40_hq_shipment.id) }
  let(:overweight_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id, payload_in_kg: 3000) }
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
  let!(:default_margin) { FactoryBot.create(:freight_margin, default_for: 'ocean', tenant: tenants_tenant, applicable: tenants_tenant, value: 0) }
  let(:itinerary_1) { FactoryBot.create(:default_itinerary, tenant: tenant) }
  let(:itinerary_2) { FactoryBot.create(:default_itinerary, tenant: tenant) }
  let!(:default_margin) { FactoryBot.create(:freight_margin, default_for: 'ocean', tenant: tenants_tenant, applicable: tenants_tenant, value: 0) }

  describe '.perform' do
    it 'returns an object containing pricings grouped by transport category (lcl)' do
      pricing_1 = FactoryBot.create(:lcl_pricing,
                                    tenant: tenant,
                                    itinerary: itinerary_1,
                                    tenant_vehicle: tenant_vehicle_1)
      FactoryBot.create(:lcl_pricing,
                        itinerary: itinerary_2,
                        tenant_vehicle: tenant_vehicle_2)
      trips = [1, 3].map do |num|
        base_date = num.days.from_now
        FactoryBot.create(:legacy_trip,
                          itinerary: pricing_1.itinerary,
                          tenant_vehicle: pricing_1.tenant_vehicle,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
      end
      schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }

      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      FactoryBot.create(:pricings_margin, pricing: pricing_1, tenant: tenants_tenant, applicable: tenants_user)

      results = described_class.new(
        schedules: schedules,
        user_pricing_id: user.id,
        cargo_classes: ['lcl'],
        dates: dates,
        dedicated_pricings_only: false,
        shipment: lcl_shipment,
        sandbox: nil
      ).perform
      expect(results.first.keys.length).to eq(1)
      expect(results.first.values.first.first['id']).to eq(pricing_1.id)
    end
    it 'returns an object containing group pricings grouped by transport category (lcl)' do
      group_1 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST1')
      FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user)
      pricing_1 = FactoryBot.create(:lcl_pricing,
                                    tenant: tenant,
                                    itinerary: itinerary_1,
                                    tenant_vehicle: tenant_vehicle_1,
                                    group_id: group_1.id)
      pricing_2 = FactoryBot.create(:lcl_pricing,
                                    tenant: tenant,
                                    itinerary: itinerary_1,
                                    tenant_vehicle: tenant_vehicle_1)

      trips = [1, 3].map do |num|
        base_date = num.days.from_now
        FactoryBot.create(:legacy_trip,
                          itinerary: pricing_1.itinerary,
                          tenant_vehicle: pricing_1.tenant_vehicle,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
        FactoryBot.create(:legacy_trip,
                          itinerary: pricing_2.itinerary,
                          tenant_vehicle: pricing_2.tenant_vehicle,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
      end
      schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }

      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      FactoryBot.create(:freight_margin, tenant: tenants_tenant, applicable: tenants_tenant)

      results = described_class.new(
        schedules: schedules,
        user_pricing_id: user.id,
        cargo_classes: ['lcl'],
        dates: dates,
        dedicated_pricings_only: false,
        shipment: lcl_shipment,
        sandbox: nil
      ).perform
      expect(results.first.keys.length).to eq(1)
      expect(results.first.values.first.first['id']).to eq(pricing_1.id)
    end
    it 'returns an object containing pricings grouped by transport category (fcl)' do
      pricing_1 = FactoryBot.create(:fcl_20_pricing,
                                    itinerary: itinerary_1,
                                    tenant: tenant,
                                    tenant_vehicle: tenant_vehicle_1)
      pricing_2 = FactoryBot.create(:fcl_40_pricing,
                                    tenant: tenant,
                                    itinerary: itinerary_1,
                                    tenant_vehicle: tenant_vehicle_1)
      pricing_3 = FactoryBot.create(:fcl_40_hq_pricing,
                                    tenant: tenant,
                                    itinerary: itinerary_1,
                                    tenant_vehicle: tenant_vehicle_1)
      FactoryBot.create(:pricings_margin, pricing: pricing_1, tenant: tenants_tenant, applicable: tenants_user)
      FactoryBot.create(:pricings_margin, pricing: pricing_2, tenant: tenants_tenant, applicable: tenants_user)
      FactoryBot.create(:pricings_margin, pricing: pricing_3, tenant: tenants_tenant, applicable: tenants_user)

      trips = [1, 3].map do |num|
        base_date = num.days.from_now
        FactoryBot.create(:legacy_trip,
                          itinerary: itinerary_1,
                          load_type: 'container',
                          tenant_vehicle: tenant_vehicle_1,
                          closing_date: base_date - 4.days,
                          start_date: base_date,
                          end_date: base_date + 30.days)
      end
      schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }
      dates = {
        start_date: schedules.first.etd,
        end_date: schedules.first.etd,
        closing_start_date: schedules.first.closing_date,
        closing_end_date: schedules.first.closing_date
      }

      results = described_class.new(
        schedules: schedules,
        user_pricing_id: user.id,
        cargo_classes: %w(fcl_20 fcl_40 fcl_40_hq),
        dates: dates,
        dedicated_pricings_only: false,
        shipment: fcl_20_shipment,
        sandbox: nil
      ).perform

      expect(results.first.keys.length).to eq(3)
      expect(results.first['fcl_40_hq'].first['id']).to eq(pricing_3.id)
      expect(results.first['fcl_40'].first['id']).to eq(pricing_2.id)
      expect(results.first['fcl_20'].first['id']).to eq(pricing_1.id)
    end
    it 'returns pricings valid for closing_dates if departure dates return nil' do
      Timecop.freeze(Date.parse('2019/01/25')) do
        pricing_1 = FactoryBot.create(:lcl_pricing,
                                      itinerary: itinerary_1,
                                      tenant_vehicle: tenant_vehicle_1,
                                      tenant: tenant,
                                      effective_date: Date.parse('01/01/2019'),
                                      expiration_date: Date.parse('31/01/2019'))
        trip = FactoryBot.create(:legacy_trip,
                                 start_date: Date.parse('02/02/2019'),
                                 end_date: Date.parse('28/02/2019'),
                                 closing_date: Date.parse('28/01/2019'),
                                 tenant_vehicle: tenant_vehicle_1,
                                 itinerary: itinerary_1)
        FactoryBot.create(:pricings_margin,
                          pricing: pricing_1,
                          tenant: tenants_tenant,
                          applicable: tenants_user,
                          effective_date: Date.today,
                          expiration_date: Date.today + 32.days)

        schedules = [Legacy::Schedule.from_trip(trip)]
        dates = {
          start_date: schedules.first.etd,
          end_date: schedules.first.etd,
          closing_start_date: schedules.first.closing_date,
          closing_end_date: schedules.first.closing_date
        }

        results = described_class.new(
          schedules: schedules,
          user_pricing_id: user.id,
          cargo_classes: ['lcl'],
          dates: dates,
          dedicated_pricings_only: false,
          shipment: lcl_shipment,
          sandbox: nil
        ).perform
        expect(results.first.keys.length).to eq(1)
        expect(results.first.values.first.first['id']).to eq(pricing_1.id)
      end
    end

    describe '.pricings_for_cargo_classes_and_groups' do
      it 'returns the correct group pricings over the base pricing' do
        group_1 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST1')
        FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user)
        pricing_1 = FactoryBot.create(:lcl_pricing,
                                      tenant: tenant,
                                      itinerary: itinerary_1,
                                      tenant_vehicle: tenant_vehicle_1,
                                      group_id: group_1.id)
        pricing_2 = FactoryBot.create(:lcl_pricing,
                                      tenant: tenant,
                                      itinerary: itinerary_1,
                                      tenant_vehicle: tenant_vehicle_1)
        trips = [1, 3].map do |num|
          base_date = num.days.from_now
          FactoryBot.create(:legacy_trip,
                            itinerary: pricing_1.itinerary,
                            tenant_vehicle: pricing_1.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
          FactoryBot.create(:legacy_trip,
                            itinerary: pricing_2.itinerary,
                            tenant_vehicle: pricing_2.tenant_vehicle,
                            closing_date: base_date - 4.days,
                            start_date: base_date,
                            end_date: base_date + 30.days)
        end
        schedules = trips.map { |t| Legacy::Schedule.from_trip(t) }

        dates = {
          start_date: schedules.first.etd,
          end_date: schedules.last.eta,
          closing_start_date: schedules.first.closing_date,
          closing_end_date: schedules.last.closing_date
        }
        results = described_class.new(
          schedules: schedules,
          user_pricing_id: user.id,
          cargo_classes: ['lcl'],
          dates: dates,
          dedicated_pricings_only: false,
          shipment: lcl_shipment,
          sandbox: nil
        ).pricings_for_cargo_classes_and_groups

        expect(results).to match_array([pricing_1])
      end
    end
  end
end
