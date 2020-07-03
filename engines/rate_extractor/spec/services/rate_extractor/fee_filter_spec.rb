# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateExtractor::FeeFilter do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  context 'when cargo is LCL' do
    let(:cargo_rate) { FactoryBot.create(:rates_cargo, :lcl, cbm_ratio: 50) }
    let(:section_rate) { cargo_rate.section }
    let(:kg_based_fee) { FactoryBot.create(:kg_based_fee, cargo: cargo_rate, kg_range: 10..200) }
    let(:unit_based_fee) { FactoryBot.create(:unit_based_fee, cargo: cargo_rate, unit_range: 1..3) }
    let(:km_based_fee) { FactoryBot.create(:km_based_fee, cargo: cargo_rate) }
    let(:cbm_based_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_rate, cbm_range: 1..10) }
    let(:wm_based_fee) { FactoryBot.create(:wm_based_fee, cargo: cargo_rate, wm_range: 10..200) }
    let(:stowage_based_fee) { FactoryBot.create(:stowage_based_fee, cargo: cargo_rate, stowage_range: 10..200) }

    let!(:un_applicable_fees) do
      FactoryBot.create_list(:rates_fee, 3,
                             cargo: cargo_rate,
                             kg_range: (1000..2000),
                             stowage_range: (1000..2000),
                             km_range: (1000..2000),
                             cbm_range: (1000..2000),
                             wm_range: (1000..2000),
                             unit_range: (1000..2000))
    end

    let(:cargo) do
      FactoryBot.create(:cargo_cargo,
                        units: FactoryBot.create_list(:lcl_unit, 2,
                                                      volume_value: 7,
                                                      weight_value: 7,
                                                      quantity: 1))
    end

    let(:decorated_cargo) { RateExtractor::Decorators::Cargo.new(cargo) }
    let(:decorated_section_rate) { RateExtractor::Decorators::SectionRate.new(section_rate) }
    let(:klass) { described_class.new(consolidation: true, desired_date: 1.month.from_now, cargo_rate: cargo_rate, section_rate: section_rate, cargo: decorated_cargo) }

    let(:decorated_section) { instance_double(RateExtractor::Decorators::SectionRate) }

    before do
      allow(RateExtractor::Decorators::SectionRate).to receive(:new).and_return(decorated_section)
      allow(decorated_section).to receive(:carriage_distance).and_return(6)
    end

    it 'filters the fees by the KG range' do
      expected_fees = [kg_based_fee.id]
      expect(klass.fees.ids).to eq expected_fees
    end

    it 'filters the fees by the number of units/items' do
      expected_fees = [unit_based_fee.id]
      expect(klass.fees.ids).to eq expected_fees
    end

    it 'filters the fees by the weight measure' do
      expected_fees = [wm_based_fee.id]
      expect(klass.fees.ids).to eq expected_fees
    end

    it 'filters the fees by trucking distance' do
      expected_fees = [km_based_fee.id]
      expect(klass.fees.ids).to eq expected_fees
    end

    it 'filters the fees by the cargo volume' do
      expected_fees = [cbm_based_fee.id]
      expect(klass.fees.ids).to eq expected_fees
    end

    it 'filters the fees by the stowage_factor' do
      expected_fees = [stowage_based_fee.id]
      expect(klass.fees.ids).to eq expected_fees
    end

    it 'filters out the unapplicable fees' do
      expected_fees = [kg_based_fee, unit_based_fee, km_based_fee, cbm_based_fee, wm_based_fee, stowage_based_fee].pluck(:id)
      unexpected_fees = un_applicable_fees.pluck(:id)

      aggregate_failures do
        expect(klass.fees.ids).to match_array expected_fees
        expect(klass.fees.ids).not_to include unexpected_fees
      end
    end
  end

  context 'when applicable fees are found' do
    it 'adds the target cargo to the fee' do
    end
  end
end
