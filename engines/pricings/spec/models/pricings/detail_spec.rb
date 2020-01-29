# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe Detail, type: :model do
    context 'instance methods' do
      let!(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
      let(:pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant) }
      let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }

      let!(:margin) do
        FactoryBot.create(:pricings_margin,
                          pricing: pricing,
                          tenant: tenants_tenant,
                          applicable: tenants_tenant)
      end

      let!(:margin_detail) { FactoryBot.create(:pricings_detail, margin: margin, charge_category_id: pricing.fees.first.charge_category_id) }

      describe '.fee_code' do
        it 'renders the fee_code ' do
          expect(margin_detail.fee_code).to eq('bas')
        end
      end

      describe '.rate_basis' do
        it 'renders the rate_basis' do
          expect(margin_detail.rate_basis).to eq('PER_WM')
        end
      end

      describe '.itinerary_name' do
        it 'renders the itinerary_name with pricing attached' do
          expect(margin_detail.itinerary_name).to eq('Gothenburg - Shanghai')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_details
#
#  id                 :uuid             not null, primary key
#  operator           :string
#  value              :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  margin_id          :uuid
#  sandbox_id         :uuid
#  tenant_id          :uuid
#
# Indexes
#
#  index_pricings_details_on_margin_id   (margin_id)
#  index_pricings_details_on_sandbox_id  (sandbox_id)
#  index_pricings_details_on_tenant_id   (tenant_id)
#
