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
      it 'calcs the volume from inputs with air' do
        expect(CargoItem.calc_chargeable_weight_from_values(1.5, 1000, 'air')).to eq(1000)
      end

      it 'calcs the volume from inputs with rail' do
        expect(CargoItem.calc_chargeable_weight_from_values(1.5, 1000, 'rail')).to eq(1000)
      end

      it 'calcs the volume from inputs with ocean' do
        expect(CargoItem.calc_chargeable_weight_from_values(1.5, 1000, 'ocean')).to eq(1500)
      end

      it 'calcs the volume from inputs with trucking' do
        expect(CargoItem.calc_chargeable_weight_from_values(1.5, 1000, 'trucking')).to eq(1000)
      end

      it 'calcs the volume from inputs with truck' do
        expect(CargoItem.calc_chargeable_weight_from_values(1.5, 1000, 'truck')).to eq(1000)
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
  end
end

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint           not null, primary key
#  cargo_class        :string
#  chargeable_weight  :decimal(, )
#  customs_text       :string
#  dangerous_goods    :boolean
#  dimension_x        :decimal(, )
#  dimension_y        :decimal(, )
#  dimension_z        :decimal(, )
#  hs_codes           :string           default([]), is an Array
#  payload_in_kg      :decimal(, )
#  quantity           :integer
#  stackable          :boolean          default(TRUE)
#  unit_price         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_item_type_id :integer
#  sandbox_id         :uuid
#  shipment_id        :integer
#
# Indexes
#
#  index_cargo_items_on_sandbox_id  (sandbox_id)
#
