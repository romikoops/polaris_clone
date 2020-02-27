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
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:itinerary) { FactoryBot.create(:default_itinerary, tenant: tenant) }
  let(:trips) do
    [1, 3].map do |num|
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
      target: tenants_user,
      tenant: tenants_tenant,
      type: :freight_margin,
      args: args
    )
  end
  let(:target_shipment) { lcl_shipment }
  let(:pricing) { FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, tenant: tenant) }

  before do
    FactoryBot.create(:profiles_profile, user_id: tenants_user.id)
    FactoryBot.create(:tenants_scope, content: {}, target: tenants_tenant)
    FactoryBot.create(:freight_margin, default_for: 'ocean', tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
  end

  describe 'fee_keys' do
    let(:args) do
      {
        sandbox: nil,
        schedules: schedules,
        itinerary_id: itinerary.id,
        cargo_class_count: target_shipment.cargo_classes.count
      }
    end

    it 'returns an empty array when no variables are present' do
      expect(klass.fee_keys).to match_array([])
    end
  end

  describe 'sanitize_date' do
    let(:args) do
      {
        sandbox: nil,
        schedules: schedules,
        itinerary_id: itinerary.id,
        cargo_class_count: target_shipment.cargo_classes.count
      }
    end

    it 'returns a DateTime' do
      expect(klass.sanitize_date('2020/12/31')).to eq(DateTime.parse('2020/12/31'))
    end
  end

  describe 'type error' do
    context 'without schedules' do
      let(:args) do
        {
          sandbox: nil,
          pricing: pricing,
          schedules: [],
          cargo_class_count: target_shipment.cargo_classes.count,
          without_meta: true
        }
      end

      it 'raises an error when there are no schedules and the type is freight margin' do
        expect { described_class.new(target: tenants_user, tenant: tenants_tenant, type: :freight_margin, args: args) }.to raise_error(Pricings::Manipulator::MissingArgument)
      end
    end

    it 'raises an error when there is no target' do
      expect { described_class.new(target: nil, tenant: tenants_tenant, type: :freight_margin, args: args) }.to raise_error(Pricings::Manipulator::MissingArgument)
    end
  end

  describe '.find_applicable_margins' do
    context 'with freight pricings and user margin' do
      let!(:user_margin) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_user) }

      it 'returns the applicable margin attached to the user' do
        margins = klass.find_applicable_margins
        expect(margins.first[:margin]).to eq(user_margin)
      end
    end

    context 'with freight pricings and tenant margin' do
      let!(:tenant_margin) { FactoryBot.create(:freight_margin, pricing: pricing, tenant: tenants_tenant, applicable: tenants_tenant) }

      it 'returns the applicable margin attached to the tenant when the user has none' do
        margins = klass.find_applicable_margins
        expect(margins.first[:margin]).to eq(tenant_margin)
      end
    end
  end
end
