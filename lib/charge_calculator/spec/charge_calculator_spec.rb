# frozen_string_literal: true

RSpec.describe ChargeCalculator do
  describe '#calculate' do
    context 'with valid arguments' do
      it 'returns a price (node tree)' do
        expect(described_class.calculate(
                 shipment_params: {},
                 pricings: []
               )).to be_a(ChargeCalculator::Models::Price)
      end
    end

    context 'with invalid arguments' do
      it 'raises an ArgumentError' do
        expect { described_class.calculate }.to raise_error(ArgumentError)
      end
    end
  end
end
