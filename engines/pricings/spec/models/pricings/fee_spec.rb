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
          expect(result.keys).to eq(['BAS'])
          expect(result['BAS']['rate']).to eq(1111)
          expect(result['BAS']['base']).to eq(1)
          expect(result['BAS']['rate_basis']).to eq('PER_WM')
          expect(result['BAS']['currency']).to eq('EUR')
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
