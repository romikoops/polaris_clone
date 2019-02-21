# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Models::Base do
  subject { described_class.new(data: { payload: '100.0' }) }

  describe '#method_missing' do
    it 'accesses a given data attribute' do
      expect(subject.payload).to eq('100.0')
    end

    it 'raises a NoMethodError if attribute cannot be found' do
      expect { subject.foo }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to_missing?' do
    subject { described_class.new(data: { one: 1 }) }

    it 'successfully' do
      expect(subject.respond_to?(:one)).to be_truthy
      expect(subject.respond_to?(:two)).to be_falsey
    end
  end
end
