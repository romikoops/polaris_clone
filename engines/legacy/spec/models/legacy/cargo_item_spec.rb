# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe CargoItem, type: :model do
    describe '.extract' do
      it 'initialize the model from the attributes' do
        attributes = FactoryBot.attributes_for(:legacy_cargo_item)
        target = CargoItem.extract([attributes]).first

        expect(target.cargo_class).to eq(attributes[:cargo_class])
      end
    end

    describe '.calc_chargeable_weight_from_values' do
      it 'calcs the volume from inputs' do
        expect(CargoItem.calc_chargeable_weight_from_values(1.5, 1000, 'ocean')).to eq(1500)
      end
    end

    describe '#volume' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.volume).to eq(0.008)
      end
    end

    describe '#payload_in_tons' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.payload_in_tons).to eq(0.2)
      end
    end

    describe '#calc_chareable_weight' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.calc_chargeable_weight('ocean')).to eq(200)
      end
    end

    describe '#set_chargeable_weight!' do
      it 'calculates the chargeableweight and set it' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.set_chargeable_weight!).to eq(200)
      end
    end

    describe '#valid_for_mode_of_transport?' do
      it 'validates the mode of transport acorging to the max dimensions' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.valid_for_mode_of_transport?('ocean')).to eq(true)
      end
    end

    describe '#with_cargo_type?' do
      it 'serializes the model with extra properties' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.with_cargo_type['cargo_item_type']).to have_key('description')
      end
    end
  end
end
