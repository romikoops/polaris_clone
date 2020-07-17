# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateExtractor::ChargeableWeight::Applicable::Comparative do
  describe 'calculating chargeable weight when tenant configuration is set as comparative' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:quotation) { FactoryBot.create(:quotations_quotation) }
    let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }

    before do
      FactoryBot.create(:lcl_unit,
        cargo: cargo,
        width_value: 0.10,
        length_value: 0.15,
        height_value: 0.20,
        weight_value: 30.0 / 45.0,
        stackable: stackable,
        quantity: 45)
      FactoryBot.create(:lcl_unit,
        cargo: cargo,
        width_value: 0.30,
        length_value: 0.30,
        height_value: 0.25,
        weight_value: 36.0 / 15.0,
        stackable: stackable,
        quantity: 15)
      FactoryBot.create(:lcl_unit,
        cargo: cargo,
        width_value: 0.25,
        length_value: 0.25,
        height_value: 0.20,
        weight_value: 168.0 / 32.0,
        stackable: stackable,
        quantity: 32)
    end

    context 'when cargo is stackable' do
      let(:stackable) { true }
      let(:section_rate) { FactoryBot.create(:rates_section, organization: organization, ldm_ratio: 1000, ldm_threshold: 48_000) }
      let(:cargo_rate) { FactoryBot.create(:rates_cargo, section: section_rate, cbm_ratio: 200) }
      let(:klass) { described_class.new(cargo: cargo, cargo_rate: cargo_rate) }

      it 'calculates the chargeable weight as the total cargo weight' do
        expected_weight = cargo.total_weight

        expect(klass.chargeable_weight).to eq expected_weight
      end
    end

    context 'with cargo is not stackable' do
      let(:stackable) { false }
      let(:decorated_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo, context: { rate: cargo_rate }) }
      let(:section_rate) { FactoryBot.create(:rates_section, organization: organization, ldm_ratio: 1000, ldm_threshold: 0.5, ldm_measurement: :load_meters) }
      let(:cargo_rate) { FactoryBot.create(:rates_cargo, section: section_rate, cbm_ratio: 200) }
      let(:klass) { described_class.new(cargo: decorated_cargo, cargo_rate: cargo_rate) }

      it 'calculates the chargeable weight as the sum of load meterage weight of all cargo units' do
        expected_weight = cargo.units.inject(Measured::Weight.new(0.0, :kg)) { |total, unit| total + Measured::Weight.new(unit.total_area.value / section_rate.ldm_area_divisor * section_rate.ldm_ratio, :kg) }

        expect(klass.chargeable_weight).to eq expected_weight
      end
    end
  end
end
