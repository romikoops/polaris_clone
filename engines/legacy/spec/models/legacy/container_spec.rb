# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Container, type: :model do
    let(:container) { FactoryBot.build(:legacy_container, weight_class: nil, size_class: 'fcl') }
    let(:container_attributes) { FactoryBot.attributes_for(:legacy_container) }

    describe '.extract' do
      it 'initialize the model from the attributes' do
        containers = described_class.extract([container_attributes])

        expect(containers.first.cargo_class).to eq(container_attributes[:cargo_class])
      end
    end

    describe '#size' do
      it 'splits the size_class and returns the size' do
        expect(container.size).to eq('fcl')
      end
    end

    describe '#validate!' do
      let(:container) { FactoryBot.build(:legacy_container, weight_class: nil, size_class: 'fcl') }

      it 'populates the model before the validation' do
        expect(container.validate!).to eq(true)
      end
    end
  end
end
