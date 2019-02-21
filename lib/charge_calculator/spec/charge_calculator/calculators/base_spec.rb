# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Calculators::Base do
  subject { described_class.new }

  context 'instance methods' do
    describe '#result' do
      it 'should return raise an exception' do
        expect { subject.result }.to raise_error NotImplementedError
      end
    end
  end
end
