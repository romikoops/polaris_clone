# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Reducers::Base do
  subject { described_class.new }

  context 'instance methods' do
    describe '#apply' do
      it 'returns raise an exception' do
        expect { subject.apply }.to raise_error NotImplementedError
      end
    end
  end
end
