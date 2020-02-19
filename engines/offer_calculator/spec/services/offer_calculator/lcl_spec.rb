# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::TruckingTools, :aggregate_failures do
  let(:fees) do
    {
      'ZZB' => { value: 11.0, currency: 'USD', rate_basis: 'PER_SHIPMENT' },
      'ZZC' => { value: 22.0, currency: 'USD', rate_basis: 'PER_BILL' }
    }
  end
  let(:modifier) { 'kg' }
  let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, modifier: modifier, rates: rates, fees: fees) }
  let(:cargos) { [FactoryBot.create(:legacy_cargo_item)] }
  let(:kms) { 42 }
  let(:carriage) { 'pre' }
  let(:user) { FactoryBot.create(:legacy_user) }

  let(:trucking_tools) { described_class.new(trucking_pricing, cargos, kms, carriage, user) }
  let(:result) { trucking_tools.perform }

  describe '.perform' do
    context 'when load type is LCL pre-carriage (PER_KG)' do
      let(:rates) { { kg: [{ rate: { base: 1.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_KG' }, min_kg: 0.0, max_kg: 2000.0 }] } }

      it 'calculates fares' do
        expect(result.dig(:total, :value)).to eq 47_533.0
      end
    end

    context 'when load type is LCL pre-carriage (PER_CBM)' do
      let(:rates) { { kg: [{ rate: { base: 1.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_CBM' }, min_kg: 0.0, max_kg: 2000.0 }] } }

      it 'calculates fares' do
        expect(result.dig(:total, :value)).to eq 34.9
      end
    end

    context 'when load type is LCL pre-carriage (PER_X_KG)' do
      let(:rates) { { kg: [{ rate: { base: 1.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' }, min_kg: 0.0, max_kg: 2000.0 }] } }

      it 'calculates fares' do
        expect(result.dig(:total, :value)).to eq 47_533.0
      end
    end

    context 'when load type is LCL pre-carriage (PER_X_KM)' do
      let(:modifier) { 'unit_per_km' }
      let(:rates) do
        {
          km: [{ rate: { base: 1.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KM' }, min_km: 0.0, max_km: 2000.0, min_value: 273.0 }],
          unit: [{ rate: { base: 1.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_CONTAINER' }, min_unit: 1, max_unit: 10_000 }]
        }
      end

      it 'calculates fares' do
        expect(result.dig(:total, :value)).to eq 10_245.5
      end
    end

    context 'when load type is LCL pre-carriage (PER_CONTAINER)' do
      let(:modifier) { 'unit' }
      let(:rates) do
        {
          unit: [{ rate: { base: 1.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_CONTAINER' }, min_unit: 1, max_unit: 10_000 }]
        }
      end

      it 'calculates fares' do
        expect(result.dig(:total, :value)).to eq 270.5
      end
    end

    context 'when load type is LCL pre-carriage (PER_WM)' do
      let(:modifier) { 'wm' }
      let(:rates) do
        { 'wm' =>
            [{ 'rate' => { 'base' => 1, 'value' => 255, 'currency' => 'CNY', 'rate_basis' => 'PER_WM' },
               'max_wm' => '10000.0',
               'min_wm' => '0.0',
               'min_value' => 1720 }] }
      end

      it 'calculates fares' do
        expect(result.dig(:total, :value)).to eq 1720
      end
    end
  end
end
