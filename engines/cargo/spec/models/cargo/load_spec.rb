# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Load, type: :model do
    context 'aggregated' do
      let(:cargo_load) { FactoryBot.build(:cargo_load, weight: 3000, volume: 1.3, aggregated: true) }

      describe '.area' do
        it 'return the correct area' do
          expect(cargo_load.area).to eq(1.3 / Cargo::Specification::DEFAULT_HEIGHT)
        end
      end

      describe '.height' do
        it 'return the correct height' do
          expect(cargo_load.height).to eq(Cargo::Specification::DEFAULT_HEIGHT)
        end
      end

      describe '.weight_measure' do
        it 'return the correct weight_measure' do
          expect(cargo_load.weight_measure.round(6)).to eq((3/1.3).round(6))
        end
      end

      describe '.stowage' do
        it 'return the correct stowage' do
          expect(cargo_load.stowage.round(6)).to eq((1.3/3).round(6))
        end
      end

      describe '.stackable' do
        it 'return the correct stackable' do
          expect(cargo_load.stackable).to eq(true)
        end
      end
    end

    context 'single group lcl' do
      let(:cargo_load) do
        FactoryBot.create(:cargo_load,
                          groups: [
                            FactoryBot.create(:cargo_group, dimension_x: 120, dimension_y: 80, dimension_z: 140, quantity: 2, weight: 3000)
                          ])
      end

      describe '.area' do
        it 'return the correct area' do
          expect(cargo_load.area).to eq(1.92)
        end
      end

      describe '.height' do
        it 'return the correct height' do
          expect(cargo_load.height).to eq(140)
        end
      end

      describe '.stackable' do
        it 'return the correct stackable' do
          expect(cargo_load.stackable).to eq(false)
        end
      end

      describe '.weight_measure' do
        it 'return the correct weight_measure' do
          expect(cargo_load.weight_measure.round(6)).to eq((6/2.688).round(6))
        end
      end

      describe '.stowage' do
        it 'return the correct stowage' do
          expect(cargo_load.stowage).to eq(2.688/6)
        end
      end

      describe '.update_weight_and_volume' do
        it 'updates the' do
          expect(cargo_load.weight).to eq(6000)
          expect(cargo_load.volume).to eq(2.688)
          cargo_load.groups.first.update(dimension_x: 100, weight: 1500)
          expect(cargo_load.weight).to eq(3000)
          expect(cargo_load.volume).to eq(2.24)
        end
      end
    end
  end
end
