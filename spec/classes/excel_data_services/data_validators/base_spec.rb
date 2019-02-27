# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidators::Base do
  let(:tenant) { create(:tenant) }
  let(:data) {}
  let(:options) { { tenant: tenant, data: data } }
  let(:base_validator) { described_class.new(options) }

  describe '.get' do
    it 'finds the correct child class' do
      expect(described_class.get('Insertable Checks', 'Pricing')).to eq(ExcelDataServices::DataValidators::InsertableChecks::Pricing)
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
        expect(base_validator).to receive(:errors).and_return([])
        expect(base_validator.valid?).to eq(true)
      end
    end

    context 'with errors' do
      it 'indicates correctly if errors exist' do
        expect(base_validator).to receive(:errors).and_return([{ message: '123', type: :error }])
        expect(base_validator.valid?).to eq(false)
      end
    end
  end

  describe '#errors_obj' do
    it 'return the correct object' do
      expect(base_validator).to receive(:errors).and_return([{ message: '123', type: :error }])
      expect(base_validator.errors_obj).to eq(has_errors: true, errors: [{ message: '123', type: :error }])
    end
  end
end
