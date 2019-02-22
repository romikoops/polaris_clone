# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Models::CargoUnit do
  subject do
    described_class.new(data: {
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
    describe '#volume' do
      it 'calculates the correct volume from dimensions' do
        expect(subject.volume).to eq(1)
      end
    end

    describe '#goods_value' do
      it 'returns the correct goods value' do
        expect(subject.goods_value).to eq(1_200)
      end
    end
  end
end
