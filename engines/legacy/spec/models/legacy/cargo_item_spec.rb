# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe CargoItem, type: :model do
    describe '.volume' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.volume).to eq(0.008)
      end
    end

    describe '.payload_in_tons' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.payload_in_tons).to eq(0.2)
      end
    end

    describe '.calc_chareable_weight' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.calc_chargeable_weight('ocean')).to eq(200)
      end
    end
  end
end
