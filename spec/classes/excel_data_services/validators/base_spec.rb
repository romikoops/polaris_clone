# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::Base do
  let(:tenant) { create(:tenant) }
  let(:data) {}
  let(:options) { { tenant: tenant, sheet_name: 'Sheet1', data: data } }
  let(:base_validator) { described_class.new(options) }

  describe '.get' do
    it 'finds the correct child class' do
      expect(described_class.get('Insertable Checks', 'Pricing')).to eq(ExcelDataServices::Validators::InsertableChecks::Pricing)
    end
  end

  describe '.perform' do
    it 'raises a NotImplementedError' do
      expect { base_validator.perform }.to raise_error(NotImplementedError)
    end
  end

  describe '#valid?' do
    context 'without errors' do
      it 'indicates correctly if no errors exist' do
        expect(base_validator).to receive(:errors_and_warnings).and_return([])
        expect(base_validator.valid?).to eq(true)
      end
    end

    context 'with errors' do
      it 'indicates correctly if errors exist' do
        expect(base_validator).to receive(:errors_and_warnings).and_return([{ message: '123', type: :error }])
        expect(base_validator.valid?).to eq(false)
      end
    end
  end

  describe '#results' do
    it 'return the correct object' do
      expect(base_validator).to receive(:errors_and_warnings).and_return([{ message: '123', type: :error }])
      expect(base_validator.errors_and_warnings).to eq([{ message: '123', type: :error }])
    end
  end
end
