# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Calculators::Payload do
  subject { described_class.new }

  context 'instance methods' do
    describe '#result' do
      it 'should return raise an exception' do
        expect(subject.result(context: { payload: 1 }, amount: 1)).to eq 1
      end
    end
  end
end
