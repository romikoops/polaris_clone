# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe Pricing, type: :model do
    context 'class methods' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
      let(:itinerary_1) { FactoryBot.create(:default_itinerary, tenant: tenant) }
      let!(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1) }
      let!(:fcl_20_pricing) { FactoryBot.create(:fcl_20_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1) }
      let!(:fcl_40_pricing) { FactoryBot.create(:fcl_40_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1) }
      let!(:fcl_40_hq_pricing) { FactoryBot.create(:fcl_40_hq_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1) }

      describe '.for_cargo_classes' do
        it 'returns the lcl pricings only' do
          expect(::Pricings::Pricing.for_cargo_classes(['lcl']).ids).to eq([lcl_pricing.id])
        end
        it 'returns the fcl_20 & fcl_40 pricings only' do
          expect(::Pricings::Pricing.for_cargo_classes(%w(fcl_20 fcl_40)).sort).to eq([fcl_20_pricing, fcl_40_pricing].sort)
        end
      end

      describe '.for_load_type' do
        it 'returns the lcl pricings only' do
          expect(::Pricings::Pricing.for_load_type('cargo_item').sort).to eq([lcl_pricing].sort)
        end
        it 'returns the fcl_20 & fcl_40 pricings only' do
          expect(::Pricings::Pricing.for_load_type('container').sort).to eq([fcl_20_pricing, fcl_40_pricing, fcl_40_hq_pricing].sort)
        end
      end

      describe '.for_load_type' do
        it 'returns the lcl pricings only' do
          expect(::Pricings::Pricing.for_load_type('cargo_item')).to eq([lcl_pricing])
        end
        it 'returns the fcl_20 & fcl_40 pricings only' do
          expect(::Pricings::Pricing.for_load_type('container').ids.sort).to eq(
            [fcl_20_pricing.id, fcl_40_pricing.id, fcl_40_hq_pricing.id].sort
          )
        end
      end

      describe '.for_dates' do
        it 'returns the lcl pricings only' do
          expect(
            ::Pricings::Pricing.for_dates(Date.today, Date.today + 2.weeks).ids.sort
          ).to eq(
            [lcl_pricing.id, fcl_20_pricing.id, fcl_40_pricing.id, fcl_40_hq_pricing.id].sort
          )
        end
      end
    end

    context 'instance methods' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
      let(:itinerary_1) { FactoryBot.create(:default_itinerary, tenant: tenant) }
      let!(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, itinerary: itinerary_1) }
      describe '.for_table_json' do
        it 'returns the pricing as a hash' do
          result = lcl_pricing.for_table_json

          expect(result['effective_date']).to eq(lcl_pricing.effective_date)
          expect(result['expiration_date']).to eq(lcl_pricing.expiration_date)
          expect(result['wm_rate']).to eq(lcl_pricing.wm_rate)
          expect(result['tenant_id']).to eq(lcl_pricing.tenant_id)
          expect(result['itinerary_id']).to eq(lcl_pricing.itinerary_id)
          expect(result['load_type']).to eq(lcl_pricing.load_type)
          expect(result['cargo_class']).to eq(lcl_pricing.cargo_class)
          expect(result['service_level']).to eq('slowly')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_pricings
#
#  id                :uuid             not null, primary key
#  cargo_class       :string
#  effective_date    :datetime
#  expiration_date   :datetime
#  internal          :boolean          default(FALSE)
#  load_type         :string
#  wm_rate           :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  group_id          :uuid
#  itinerary_id      :bigint
#  legacy_id         :integer
#  sandbox_id        :uuid
#  tenant_id         :bigint
#  tenant_vehicle_id :integer
#  user_id           :bigint
#
# Indexes
#
#  index_pricings_pricings_on_cargo_class        (cargo_class)
#  index_pricings_pricings_on_itinerary_id       (itinerary_id)
#  index_pricings_pricings_on_load_type          (load_type)
#  index_pricings_pricings_on_sandbox_id         (sandbox_id)
#  index_pricings_pricings_on_tenant_id          (tenant_id)
#  index_pricings_pricings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_pricings_pricings_on_user_id            (user_id)
#
