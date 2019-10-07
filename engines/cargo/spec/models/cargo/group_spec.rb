require 'rails_helper'

module Cargo
  RSpec.describe Group, type: :model do
    context 'instance methods' do
      let(:group) { FactoryBot.build(:cargo_group, dimension_x: 120, dimension_y: 80, dimension_z: 140, quantity: 2, weight: 3000) }

      describe '.area' do
        it 'return the correct area' do
          expect(group.area).to eq(1.92)
        end
      end
      
      describe '.unit_area' do
        it 'return the correct area per unit' do
          expect(group.unit_area).to eq(0.96)
        end
      end

      describe '.volume' do
        it 'return the correct volume' do
          expect(group.volume).to eq(2.688)
        end
      end

      describe '.weight_measure' do
        it 'return the correct weight_measure' do
          expect(group.weight_measure.round(6)).to eq((6/2.688).round(6))
        end
      end

      describe '.stowage' do
        it 'return the correct stowage' do
          expect(group.stowage).to eq(2.688/6)
        end
      end
    end
  end
end
