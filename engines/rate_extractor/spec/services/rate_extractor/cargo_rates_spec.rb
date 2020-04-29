# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateExtractor::CargoRates do
  context 'when initialized by section rates, cargo' do
    let(:section_rates) { FactoryBot.create_list(:section_for_multiple_cargo_classes, 3) }

    let(:cargo_rates) { Rates::Cargo.all }

    context 'when cargo is lcl' do
      let(:cargo) { FactoryBot.create(:cargo_cargo, units: FactoryBot.create_list(:lcl_unit, 2)) }
      let(:decorated_cargo) { RateExtractor::Decorators::Cargo.new(cargo) }
      let(:lcl_cargo_rates) { cargo_rates.where(cargo_class: '00') }
      let(:klass) { described_class.new(section_rates: section_rates, cargo: decorated_cargo) }

      it 'returns cargo rates applicable lcl cargo on the relevant sections of the path' do
        expect(klass.rates.ids).to eq lcl_cargo_rates.ids
      end
    end

    context 'when cargo is fcl 20' do
      let(:cargo) { FactoryBot.create(:cargo_cargo, units: FactoryBot.create_list(:fcl_20_unit, 2)) }
      let(:decorated_cargo) { RateExtractor::Decorators::Cargo.new(cargo) }
      let(:fcl_20_cargo_rates) { cargo_rates.where(cargo_class: '22') }
      let(:klass) { described_class.new(section_rates: section_rates, cargo: decorated_cargo) }

      it 'returns cargo rates applicable fcl 20 cargo on the relevant sections of the path' do
        expect(klass.rates.ids).to eq fcl_20_cargo_rates.ids
      end
    end

    context 'when cargo is fcl 40' do
      let(:cargo) { FactoryBot.create(:cargo_cargo, units: FactoryBot.create_list(:fcl_40_unit, 2)) }
      let(:decorated_cargo) { RateExtractor::Decorators::Cargo.new(cargo) }
      let(:fcl_40_cargo_rates) { cargo_rates.where(cargo_class: '42') }
      let(:klass) { described_class.new(section_rates: section_rates, cargo: decorated_cargo) }

      it 'returns cargo rates applicable fcl 40 cargo on the relevant sections of the path' do
        expect(klass.rates.ids).to eq fcl_40_cargo_rates.ids
      end
    end
  end
end
