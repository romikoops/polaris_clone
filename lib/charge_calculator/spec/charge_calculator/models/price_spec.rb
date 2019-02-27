# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Models::Price do
  let(:price_attributes) do
    {
      amount: BigDecimal('100'),
      currency: 'EUR',
      category: 'base',
      description: 'Base'
    }
  end

  let(:price) { described_class.new(price_attributes) }

  let(:children_price_attributes) do
    [
      {
        amount: BigDecimal('80'),
        currency: 'EUR',
        category: 'BAS',
        description: 'BAS'
      },
      {
        amount: BigDecimal('20'),
        currency: 'EUR',
        category: 'HAS',
        description: 'HAS'
      }
    ]
  end

  let(:children) do
    children_price_attributes.map do |attributes|
      described_class.new(attributes)
    end
  end

  let(:price_with_children) { described_class.new(price_attributes.merge(children: children)) }

  context 'Initializer' do
    it 'generates a correct instance' do
      expect(price).to be_a(described_class)
      expect(price.amount).to eq(BigDecimal('100'))
      expect(price.currency).to eq('EUR')
      expect(price.category).to eq('base')
      expect(price.description).to eq('Base')
    end
  end

  describe '#to_h' do
    context 'single node' do
      it 'calculates the correct hash' do
        expect(price.to_h).to eq(
          amount: BigDecimal('100'),
          currency: 'EUR',
          category: 'base',
          description: 'Base',
          children: []
        )
      end
    end

    context '2 level tree' do
      it 'calculates the correct hash' do
        expect(price_with_children.to_h).to eq(
          amount: BigDecimal('100'),
          currency: 'EUR',
          category: 'base',
          description: 'Base',
          children: [
            {
              amount: BigDecimal('80'),
              currency: 'EUR',
              category: 'BAS',
              description: 'BAS',
              children: []
            },
            {
              amount: BigDecimal('20'),
              currency: 'EUR',
              category: 'HAS',
              description: 'HAS',
              children: []
            }
          ]
        )
      end
    end
  end
end
