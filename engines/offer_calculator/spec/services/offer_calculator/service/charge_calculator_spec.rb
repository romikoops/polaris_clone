# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::ChargeCalculator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, organization: organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, organization: organization, legacy_shipment_id: shipment.id) }
  let(:cargo_cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }
  let(:lcl_unit) do
    FactoryBot.create(:lcl_unit,
                      width_value: 1.20,
                      height_value: 1.40,
                      length_value: 0.8,
                      quantity: 2,
                      weight_value: 1200,
                      cargo: cargo_cargo)
  end
  let(:fcl_20_unit) do
    FactoryBot.create(:fcl_20_unit,
                      quantity: 2,
                      weight_value: 12_000,
                      cargo: cargo_cargo)
  end
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
                     original: pricing,
                     result: pricing.as_json)
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Unit.new(
      cargo: target_cargo,
      scope: {},
      object: manipulated_result
    )
  end
  let(:min_value) { Money.new(0, 'USD') }
  let(:max_value) { Money.new(1e12, 'USD') }
  let(:target_cargo) { lcl_unit }
  let(:fee_data) { fee.fee_data }
  let(:rate_builder_fee) do
    FactoryBot.build(:rate_builder_fee,
                     min_value: min_value,
                     max_value: max_value,
                     rate_basis: fee.rate_basis.internal_code,
                     target: target_cargo,
                     measures: measures,
                     charge_category: fee.charge_category,
                     raw_fee: fee_data)
  end
  let(:fees) { [rate_builder_fee] }
  let(:results) { described_class.charges(shipment: shipment, quotation: quotation, fees: fees) }

  context 'when calculating per_wm fee' do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }

    it 'calculates the per_wm fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.wm.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_container fee' do
    let(:fee) { FactoryBot.create(:fee_per_container, pricing: pricing) }
    let(:target_cargo) { fcl_20_unit }

    it 'calculates the per_container fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.unit.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_hbl fee' do
    let(:fee) { FactoryBot.create(:fee_per_hbl, pricing: pricing) }

    it 'calculates the per_hbl fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.shipment.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_shipment fee' do
    let(:fee) { FactoryBot.create(:fee_per_shipment, pricing: pricing) }

    it 'calculates the per_shipment fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.shipment.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_item fee' do
    let(:fee) { FactoryBot.create(:fee_per_item, pricing: pricing) }

    it 'calculates the per_item fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.unit.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_cbm fee' do
    let(:fee) { FactoryBot.create(:fee_per_cbm, pricing: pricing) }

    it 'calculates the per_cbm fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.cbm.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_kg fee' do
    let(:fee) { FactoryBot.create(:fee_per_kg, pricing: pricing) }

    it 'calculates the per_kg fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.kg.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_x_kg_flat fee' do
    let(:fee) { FactoryBot.create(:fee_per_x_kg_flat, pricing: pricing) }
    let(:rate_value) { (measures.kg.value / fee.base).ceil * fee.base }

    it 'calculates the per_x_kg_flat fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(rate_value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating per_ton fee' do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }

    it 'calculates the per_ton fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.ton.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context 'when calculating percentage fee' do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:expected_rate_value) { measures.wm.value * fee.rate * 0.1 }

    before do
      fees << FactoryBot.build(:rate_builder_fee,
                               min_value: min_value,
                               rate_basis: 'PERCENTAGE',
                               target: nil,
                               measures: measures,
                               charge_category: FactoryBot.create(:puf_charge),
                               raw_fee: { rate: 0.1, rate_basis: 'PERCENTAGE' })
    end

    it 'calculates the per_ton fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(2)
        expect(results.second.value).to eq(Money.new(expected_rate_value * 100, fee.currency_name))
      end
    end
  end

  context 'when the minimum is hit' do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
    let(:min_value) { Money.new(12_000_000, 'USD') }

    it 'calculates the per_ton fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(min_value)
      end
    end
  end

  context 'when the maximum is hit' do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
    let(:max_value) { Money.new(100, 'USD') }

    it 'calculates the per_ton fee correctly' do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(max_value)
      end
    end
  end

  context 'when an error occurs' do
    let(:fees) { nil }

    it 'calculates the per_ton fee correctly' do
      expect { results }.to raise_error(OfferCalculator::Errors::CalculationError)
    end
  end
end
