# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Cargo, type: :model do
    context 'aggregated' do
      cargo = FactoryBot.build(:cargo_cargo, units: [
                                 FactoryBot.build(:aggregated_unit, weight_value: 3000, volume_value: 1.3)
                               ])

      before :all do
        cargo.validate
      end

      describe '.area' do
        it 'return the correct area' do
          expected_area = 1.3 / Specification::DEFAULT_HEIGHT * 2
          expect(cargo.area).to eq(Measured::Area.new(expected_area, :m2))
        end
      end

      describe '.stowage_factor' do
        it 'return the correct stowage_factor' do
          expected_stowage_factor = (1.3 / (3000 / 1000.0)).round(6)
          expect(cargo.stowage_factor).to eq(Measured::StowageFactor.new(expected_stowage_factor, 'm3/t'))
        end
      end

      describe '.stackable' do
        it 'return the correct stackable' do
          expect(cargo.stackable?).to eq(true)
        end
      end
    end

    context 'single unit lcl' do
      cargo = FactoryBot.build(:cargo_cargo,
                               units:
                                 FactoryBot.build_list(:lcl_unit, 5,
                                                       weight_value: 3000,
                                                       quantity: 2,
                                                       width_value: 1.20,
                                                       length_value: 0.80,
                                                       height_value: 1.40))

      before :all do
        cargo.validate
      end

      describe '.area' do
        it 'return the correct area' do
          expected_area = (1.20 * 0.8) * 2 * 5
          expect(cargo.area).to eq(Measured::Area.new(expected_area, :m2))
        end
      end

      describe '.stackable' do
        it 'return the correct stackable' do
          expect(cargo.stackable?).to eq(false)
        end
      end

      describe '.stowage_factor' do
        it 'return the correct stowage_factor' do
          expected_stowage_factor = ((1.20 * 0.8 * 1.40 * 2 * 5) / (3000 * 2 * 5 / 1000.0)).round(6)
          expect(cargo.stowage_factor).to eq(Measured::StowageFactor.new(expected_stowage_factor, 'm3/t'))
        end
      end
    end

    context 'when updating units weight and volume' do
      cargo = FactoryBot.build(:cargo_cargo, units: [
                                 FactoryBot.build(:lcl_unit, weight_value: 3000,
                                                             width_value: 1.20,
                                                             length_value: 0.80,
                                                             height_value: 1.40)
                               ])

      before :all do
        cargo.validate
      end

      it 'reflects the updates on the entire cargo' do
        expect(cargo.weight).to eq(Measured::Weight.new(6000, :kg))
        expect(cargo.volume).to eq(Measured::Volume.new(2.688, :m3))
        cargo.units.first.update(width_value: 1, weight_value: 1.5)
        expect(cargo.weight).to eq(Measured::Weight.new(3, :kg))
        expect(cargo.volume).to eq(Measured::Volume.new(2.24, :m3))
      end
    end
  end
end
