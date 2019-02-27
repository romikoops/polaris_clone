# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Contexts::Base do
  subject { described_class.new }

  context 'instance methods' do
    describe '#to_h' do
      it 'returns raise an exception' do
        expect { subject.to_h }.to raise_error NotImplementedError
      end
    end

    describe '#hash' do
      it 'returns raise an exception' do
        expect { subject.hash }.to raise_error NotImplementedError
      end
    end
  end
end
