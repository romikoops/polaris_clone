# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Conversion do
  let(:fixed_tenant) { FactoryBot.create(:legacy_tenant, scope: { 'fixed_exchange_rates' => true }) }
  let(:fluid_tenant) { FactoryBot.create(:legacy_tenant, name: 'Fluid', subdomain: 'fluid') }
  let!(:fixed_currency) { FactoryBot.create(:legacy_currency, tenant_id: fixed_tenant.id) }
  let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: fluid_tenant.id) }

  before { FactoryBot.create(:legacy_currency) }

  describe '.sum_and_convert' do
    it 'takes a hash of values in different currencies and convertes them into base currency' do
      hash = {
        'EUR' => 120,
        'USD' => 134,
        'ZAR' => 12_345
      }
      result = described_class.new(base: 'EUR', tenant_id: fixed_tenant.id).sum_and_convert(hash)
      expect(result).to eq(239.59437870720262)
    end
  end

  describe '.sum_and_convert_cargo' do
    it 'takes a hash of values in different currencies and convertes them into base currency' do
      hash = {
        'BAS' => { 'currency' => 'EUR', 'value' => 10 },
        'HAS' => { 'currency' => 'USD', 'value' => 10 },
        'GAS' => { 'currency' => 'SEK', 'value' => 10 }
      }
      result = described_class.new(base: 'EUR', tenant_id: fixed_tenant.id).sum_and_convert_cargo(hash)

      expect(result).to eq(18.924953634865865)
    end
  end

  describe '.convert' do
    it 'converts from one currency to another' do
      result = described_class.new(base: 'EUR', tenant_id: fixed_tenant.id).convert(1, 'USD', 'EUR')
      expect(result).to eq(0.8924953634865866)
    end

    it 'doesnt convert if currencies are the same' do
      result = described_class.new(base: 'EUR', tenant_id: fixed_tenant.id).convert(1, 'EUR', 'EUR')
      expect(result).to eq(1)
    end
  end

  describe '.round_value' do
    context 'with continuous_rounding' do
      before { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { continuous_rounding: true }) }

      it 'rounds the value if the scope is set for continuous_rounding' do
        result = described_class.new(base: 'EUR', tenant_id: fluid_tenant.id).round_value(1.120454)
        expect(result).to eq(1.12)
      end
    end

    it 'doesnt round the value if the scope is set for continuous_rounding' do
      result = described_class.new(base: 'EUR', tenant_id: fixed_tenant.id).round_value(1.120454)
      expect(result).to eq(1.120454)
    end
  end
end
