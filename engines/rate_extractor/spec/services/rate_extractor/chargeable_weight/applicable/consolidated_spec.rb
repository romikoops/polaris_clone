# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateExtractor::ChargeableWeight::Applicable::Consolidated do
  describe 'calculating chargeable weight as consolidated for the whole cargo' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:quotation) { FactoryBot.create(:quotations_quotation) }

    context 'when ldm weight is the highest' do
      let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }

      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 1.10,
          length_value: 0.15,
          height_value: 0.10,
          weight_value: 30.0 / 45.0,
          stackable: true,
          quantity: 15)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.30,
          length_value: 0.30,
          height_value: 0.15,
          weight_value: 36.0 / 15.0,
          stackable: true,
          quantity: 15)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          width_value: 0.25,
          length_value: 0.25,
          height_value: 0.10,
          weight_value: 168.0 / 32.0,
          stackable: true,
          quantity: 12)
      end

      let(:decorated_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo, context: { rate: cargo_rate }) }
      let(:section_rate) { FactoryBot.create(:rates_section, organization: organization, ldm_ratio: 100, ldm_threshold: 1.5, ldm_measurement: :load_meters) }
      let(:cargo_rate) { FactoryBot.create(:rates_cargo, section: section_rate, cbm_ratio: cbm_ratio) }
      let(:cbm_ratio) { 100 }

      let(:klass) { described_class.new(cargo: decorated_cargo, cargo_rate: cargo_rate) }

      it 'calculates the chargeable weight as the volumteric weight of each unit' do
        expected_weight = Measured::Weight.new(cargo.total_area.value / 2.4 * section_rate.ldm_ratio, :kg)

        expect(klass.chargeable_weight).to eq expected_weight
      end
    end
  end
end
