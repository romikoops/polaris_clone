# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Contexts::CargoUnit do
  subject { described_class.new(cargo_unit: cargo_unit, pricing: {}) }

  let(:cargo_unit) do
    ChargeCalculator::Models::CargoUnit.new(data: {
                                              id: 1,
                                              quantity: 2,
                                              payload: '1_130.0',
                                              dimensions: {
                                                x: '100.0',
                                                y: '100.0',
                                                z: '100.0'
                                              },
                                              goods_value: '1_200.00'
                                            })
  end

  context 'instance methods' do
    describe '#to_h' do
      it 'returns a hash' do
        expect(subject.to_h).to be_a Hash
      end

      context 'dimensions' do
        it 'converts dimensions correctly' do
          expect(subject[:dimensions]).to eq(x: 100, y: 100, z: 100)
        end
      end
    end
  end
end
