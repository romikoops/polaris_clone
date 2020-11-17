# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateExtractor::ChargeableWeight::Applicable::Regular do
  describe 'calculating chargeable weight for each unit separately' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:quotation) { FactoryBot.create(:quotations_quotation) }
    let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }

    context 'when volumetric weight is the highest' do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 1.10,
          length_value: 1.15,
          height_value: 1.20,
          weight_value: 30.0 / 45.0,
          stackable: false,
          quantity: 45)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 1.25,
          length_value: 1.30,
          height_value: 1.25,
          weight_value: 1.0,
          stackable: false,
          quantity: 50)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 1.25,
          length_value: 1.25,
          height_value: 1.20,
          weight_value: 168.0 / 32.0,
          stackable: false,
          quantity: 32)
      end

      let(:decorated_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo, context: { rate: cargo_rate }) }
      let(:section_rate) { FactoryBot.create(:rates_section, organization: organization, ldm_ratio: 1000, ldm_threshold: 10, ldm_measurement: :height) }
      let(:cargo_rate) { FactoryBot.create(:rates_cargo, section: section_rate, cbm_ratio: cbm_ratio) }
      let(:cbm_ratio) { 200 }

      let(:klass) { described_class.new(cargo: decorated_cargo, cargo_rate: cargo_rate) }

      it 'calculates the chargeable weight as the volumteric weight of each unit' do
        expected_volumetric_weight = cargo.units.inject(Measured::Weight.new(0.0, :kg)) { |total, unit| total + Measured::Weight.new(unit.total_volume.value * cbm_ratio, :kg) }

        expect(klass.chargeable_weight).to eq expected_volumetric_weight
      end
    end

    context 'when payload weight is the highest' do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.10,
          length_value: 0.15,
          height_value: 0.20,
          weight_value: 100.0 / 45.0,
          stackable: false,
          quantity: 45)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.25,
          length_value: 0.30,
          height_value: 0.25,
          weight_value: 100.0,
          stackable: false,
          quantity: 50)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.25,
          length_value: 0.25,
          height_value: 0.20,
          weight_value: 168.0 / 32.0,
          stackable: false,
          quantity: 32)
      end

      let(:decorated_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo, context: { rate: cargo_rate }) }
      let(:section_rate) { FactoryBot.create(:rates_section, organization: organization, ldm_ratio: 1000, ldm_threshold: 10, ldm_measurement: :height) }
      let(:cargo_rate) { FactoryBot.create(:rates_cargo, section: section_rate, cbm_ratio: cbm_ratio) }
      let(:cbm_ratio) { 200 }

      let(:klass) { described_class.new(cargo: decorated_cargo, cargo_rate: cargo_rate) }

      it 'calculates the chargeable weight as the sum of payload weight of all units' do
        expect(klass.chargeable_weight).to eq cargo.total_weight
      end
    end

    context 'when ldm weight is the highest' do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.10,
          length_value: 0.15,
          height_value: 3.20,
          weight_value: 10.0 / 45.0,
          stackable: false,
          quantity: 45)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.25,
          length_value: 0.30,
          height_value: 3.25,
          weight_value: 10.0,
          stackable: false,
          quantity: 50)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.25,
          length_value: 0.25,
          height_value: 3.20,
          weight_value: 90.0 / 32.0,
          stackable: false,
          quantity: 32)
      end

      let(:decorated_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo, context: { rate: cargo_rate }) }
      let(:section_rate) { FactoryBot.create(:rates_section, organization: organization, ldm_ratio: 2000, ldm_threshold: 1, ldm_measurement: :height) }
      let(:cargo_rate) { FactoryBot.create(:rates_cargo, section: section_rate, cbm_ratio: cbm_ratio) }
      let(:cbm_ratio) { 100 }

      let(:klass) { described_class.new(cargo: decorated_cargo, cargo_rate: cargo_rate) }

      it 'calculates the chargeable weight as the sum of ldm weights of each unit' do
        expected_ldm_weight = cargo.units.inject(Measured::Weight.new(0.0, :kg)) { |total, unit| total + Measured::Weight.new(unit.total_area.value / 2.4 * section_rate.ldm_ratio, :kg) }

        expect(klass.chargeable_weight).to eq expected_ldm_weight
      end
    end
  end
end
