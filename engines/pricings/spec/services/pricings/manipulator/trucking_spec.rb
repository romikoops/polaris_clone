# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Manipulator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle]) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', organization: organization) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |group|
      FactoryBot.create(:groups_membership, member: user, group: group)
    end
  end
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, organization: organization, user: user) }
  let(:itinerary) { FactoryBot.create(:default_itinerary, organization: organization) }
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
  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, organization: organization) }
  let(:bas_charge_category) { FactoryBot.create(:bas_charge, organization: organization) }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, organization: organization) }

  let(:args) do
    {
      sandbox: nil,
      pricing: pricing,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count,
      without_meta: true
    }
  end

  let(:klass) do
    described_class.new(
      target: user,
      organization: organization,
      type: :freight_margin,
      args: args
    )
  end
  let(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization) }
  let(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, tenant_vehicle: tenant_vehicle, organization: organization) }
  let(:target_shipment) { lcl_shipment }
  let(:hub) { itinerary.hubs.first }

  before do
    FactoryBot.create(:profiles_profile, user_id: user.id)
    FactoryBot.create(:organizations_scope, content: {}, target: organization)
    %w[ocean trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, organization: organization, applicable: organization, value: 0)
      ]
    end
  end

  describe '.perform' do
    let(:margin_type) { :trucking_pre_margin }
    let(:args) do
      {
        sandbox: nil,
        trucking_pricing: trucking_pricing,
        cargo_class_count: target_shipment.cargo_classes.count,
        date: Time.zone.today + 5.days,
        without_meta: true
      }
    end
    let(:klass) do
      described_class.new(
        target: user,
        organization: organization,
        type: margin_type,
        args: args
      )
    end
    let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, hub: hub, organization: organization, carriage: 'pre') }

    context 'with manipulated trucking pricing attached to the user' do
      before do
        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: user)
      end

      it 'returns the manipulated trucking pricing attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['puf'])
          expect(manipulated_pricings.first.dig('fees', 'puf', 'value')).to eq(275)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'rate_basis')).to eq('PER_SHIPMENT')
          expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        end
      end
    end

    context 'with manipulated trucking pricing attached to the user with multiple margins' do
      before do
        FactoryBot.create(:trucking_pre_margin,
                          destination_hub: hub,
                          organization: organization,
                          applicable: user,
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:trucking_pre_margin,
                          destination_hub: hub,
                          organization: organization,
                          applicable: group,
                          value: 10,
                          operator: '+',
                          effective_date: (Time.zone.today + 1.day).beginning_of_day,
                          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end

      let!(:manipulated_pricings) { klass.perform.first }

      it 'returns the manipulated trucking pricing attached to the user with multiple margins' do
        manipulated_pricings.sort_by! { |m| m['effective_date'] }
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
          expect(manipulated_pricings.map { |pricing| pricing.dig('flat_margins') }).to match_array([{}, { 'puf' => 0.5e1, 'trucking_pre' => 0.5e1 }, { 'puf' => 0.5e1, 'trucking_pre' => 0.5e1 }, {}])
          expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'puf', 'value') }).to match_array([250.0, 275.0, 250.0, 250.0])
          expect(manipulated_pricings.map { |pricing| pricing.dig('fees', 'puf', 'rate_basis') }.uniq).to eq(['PER_SHIPMENT'])
          expect(manipulated_pricings.map { |pricing| pricing.dig('rates', 'kg', 0, 'rate', 'value') }).to eq([0.2375e3, 0.26125e3, 0.2375e3, 0.2375e3])
        end
      end
    end

    context 'with manipulated trucking pricing attached to the group' do
      before do
        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: group)
      end

      it 'returns the manipulated trucking pricing attached to the group' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['puf'])
          expect(manipulated_pricings.first.dig('fees', 'puf', 'value')).to eq(275)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'rate_basis')).to eq('PER_SHIPMENT')
          expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        end
      end
    end

    context 'with multiple manipulated trucking pricings when margins overlap attached to the group' do
      Timecop.freeze(Time.zone.now) do
        before do
          FactoryBot.create(:trucking_pre_margin,
                            destination_hub: hub,
                            effective_date: Time.zone.today.beginning_of_day,
                            expiration_date: (Time.zone.today + 12.days).end_of_day,
                            organization: organization,
                            applicable: group)
          FactoryBot.create(:trucking_pre_margin,
                            destination_hub: hub,
                            effective_date: (Time.zone.today + 10.days).beginning_of_day,
                            expiration_date: (Time.zone.today + 22.days).end_of_day,
                            organization: organization,
                            value: 0.5,
                            applicable: group)
        end

        it 'returns multiple manipulated trucking pricings when margins overlap attached to the group' do
          manipulated_pricings, _metadata = klass.perform
          manipulated_pricings.sort_by! { |m| m['effective_date'] }
          aggregate_failures do
            expect(manipulated_pricings.map { |tp| tp['id'] }.uniq).to match_array([trucking_pricing.id])
            expect(manipulated_pricings.map { |mp| mp[:rates].dig('kg', 0, 'rate', 'value') }).to match_array([0.26125e3, 0.391875e3, 0.35625e3, 0.2375e3])
            expect(manipulated_pricings.map { |mp| mp.dig('fees', 'puf', 'value') }).to match_array([0.275e3, 0.4125e3, 0.375e3, 0.25e3])
          end
        end
      end
    end

    context 'with manipulated trucking pricing attached to the group via company' do
      before do
        company = FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
        FactoryBot.create(:groups_group, organization: organization).tap do |company_group|
          FactoryBot.create(:groups_membership, member: company, group: company_group)
          FactoryBot.create(:trucking_on_margin, origin_hub: hub, organization: organization, applicable: company_group)
        end
      end

      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, hub: hub, organization: organization, carriage: 'on') }
      let(:margin_type) { :trucking_on_margin }

      it 'returns the manipulated trucking pricing attached to the group via company' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['puf'])
          expect(manipulated_pricings.first.dig('fees', 'puf', 'value')).to eq(275)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'rate_basis')).to eq('PER_SHIPMENT')
          expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        end
      end
    end

    context 'with manipulated trucking pricing with specific detail attached to the user' do
      before do
        FactoryBot.create(:trucking_on_margin, origin_hub: hub, organization: organization, applicable: user).tap do |tapped_margin|
          FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: puf_charge_category)
        end
      end

      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, hub: hub, organization: organization, carriage: 'on') }
      let(:margin_type) { :trucking_on_margin }

      it 'returns the manipulated trucking pricing with specific detail attached to the user' do
        manipulated_pricings, _metadata = klass.perform
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['puf'])
          expect(manipulated_pricings.first.dig('fees', 'puf', 'value')).to eq(312.5)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'rate_basis')).to eq('PER_SHIPMENT')
          expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
        end
      end
    end

    context 'with manipulated trucking pricing with specific detail and range fee attached to the user' do
      before do
        FactoryBot.create(:trucking_on_margin, origin_hub: hub, organization: organization, applicable: user).tap do |tapped_margin|
          FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: puf_charge_category)
        end
      end

      let(:trucking_pricing) do
        FactoryBot.create(:trucking_trucking,
                          hub: hub,
                          organization: organization,
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
      end
      let(:margin_type) { :trucking_on_margin }
      let!(:manipulated_pricings) { klass.perform.first }

      it 'returns the manipulated trucking correct keys and ids' do
        aggregate_failures do
          expect(manipulated_pricings.first['id']).to eq(trucking_pricing.id)
          expect(manipulated_pricings.first['fees'].keys).to eq(['puf'])
        end
      end

      it 'returns the manipulated trucking pricing with range fee' do
        aggregate_failures do
          expect(manipulated_pricings.first.dig('fees', 'puf', 'value')).to eq(21.875)
          expect(manipulated_pricings.first['rates'].dig('kg', 0, 'rate', 'value')).to eq(261.25)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'range', 0, 'cbm')).to eq(12.5)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'range', 0, 'ton')).to eq(50)
          expect(manipulated_pricings.first.dig('fees', 'puf', 'rate_basis')).to eq('PER_CBM_TON_RANGE')
        end
      end
    end

    context 'with manipulated trucking pricing with metadata attached to the user' do
      let!(:margin1) { FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: user) }
      let(:metadata) { klass.perform.second }
      let(:metadatum) { metadata.first }

      it 'returns the manipulated trucking pricing with metadata attached to the user - general info' do
        aggregate_failures do
          expect(metadatum.keys).to match_array(%i[pricing_id cargo_class fees metadata_id direction])
          expect(metadatum[:pricing_id]).to eq(trucking_pricing.id)
          expect(metadatum[:fees].keys).to eq(%i[puf trucking_lcl])
          expect(metadatum.dig(:fees, :puf, :breakdowns).length).to eq(2)
          expect(metadatum.dig(:fees, :trucking_lcl, :breakdowns).length).to eq(2)
        end
      end

      it 'returns the manipulated trucking pricing with metadata attached to the user - fee' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :puf, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :puf, :breakdowns, 1, :margin_value)).to eq(margin1.value)
        end
      end

      it 'returns the manipulated trucking pricing with metadata attached to the user -main rate' do
        aggregate_failures do
          expect(metadatum.dig(:fees, :trucking_lcl, :breakdowns, 1, :source_id)).to eq(margin1.id)
          expect(metadatum.dig(:fees, :trucking_lcl, :breakdowns, 1, :margin_value)).to eq(margin1.value)
        end
      end
    end
  end
end
