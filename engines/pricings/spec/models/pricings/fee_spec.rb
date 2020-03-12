# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe Fee, type: :model do
    context 'instance methods' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let!(:pricing) { FactoryBot.create(:pricings_pricing) }
      let!(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }

      describe '.to_fee_hash' do
        it 'returns the fee as a hash' do
          result = fee.to_fee_hash
          expect(result.keys).to eq(['bas'])
          expect(result['bas']['rate']).to eq(1111)
          expect(result['bas']['base']).to eq(1)
          expect(result['bas']['rate_basis']).to eq('PER_WM')
          expect(result['bas']['currency']).to eq('EUR')
        end
      end

      describe '.fee_name_and_code' do
        it 'returns the fee name and code' do
          expect(fee.fee_name_and_code).to eq('BAS - Basic Ocean Freight')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_fees
#
#  id                 :uuid             not null, primary key
#  base               :decimal(, )
#  currency_name      :string
#  hw_threshold       :decimal(, )
#  metadata           :jsonb
#  min                :decimal(, )
#  range              :jsonb
#  rate               :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  currency_id        :bigint
#  hw_rate_basis_id   :uuid
#  legacy_id          :integer
#  pricing_id         :uuid
#  rate_basis_id      :uuid
#  sandbox_id         :uuid
#  tenant_id          :bigint
#
# Indexes
#
#  index_pricings_fees_on_pricing_id  (pricing_id)
#  index_pricings_fees_on_sandbox_id  (sandbox_id)
#  index_pricings_fees_on_tenant_id   (tenant_id)
#
