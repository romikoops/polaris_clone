# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DatabaseInserters::Base do
  let(:tenant) { create(:tenant) }
  let(:data) {}
  let(:options) { { tenant: tenant, data: data, options: {} } }

  describe '.get' do
    it 'finds the correct child class' do
      expect(described_class.get('Pricing')).to eq(ExcelDataServices::DatabaseInserters::Pricing)
    end
  end

  describe '.insert' do
    it 'raises a NotImplementedError' do
      expect { described_class.insert(options) }.to raise_error(NotImplementedError)
    end
  end
end
