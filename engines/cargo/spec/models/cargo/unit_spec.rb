# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Unit, type: :model do
    context 'instance methods' do
      unit = FactoryBot.build(:cargo_unit, :lcl, quantity: 2,
                                                 weight_value: 3000,
                                                 width_value: 1.20,
                                                 length_value: 0.80,
                                                 height_value: 1.40)

      before :all do
        unit.validate
      end

      describe '.total_area' do
        it 'return the correct area' do
          expected_area = 1.2 * 0.8 * 2
          expect(unit.total_area).to eq(Measured::Area.new(expected_area, :m2))
        end
      end

      describe '.unit_area' do
        it 'return the correct area per unit' do
          expect(unit.area).to eq(Measured::Area.new(0.96, :m2))
        end
      end

      describe '.total_volume' do
        it 'return the correct volume' do
          expected_volume = 1.20 * 0.8 * 1.40 * 2
          expect(unit.total_volume).to eq(Measured::Volume.new(expected_volume, :m3))
        end
      end

      describe '.stowage_factor' do
        it 'return the correct stowage_factor' do
          expected_stowage_factor = ((1.20 * 0.8 * 1.40) / (3000 / 1000.0)).round(6)
          expect(unit.stowage_factor).to eq(Measured::StowageFactor.new(expected_stowage_factor, 'm3/t'))
        end
      end
    end
  end
end
