# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::TypeValidity::Base do
  describe '.get' do
    it 'returns the specific sheet validator' do
      restructurer_name = 'saco_shipping'
      type_validator = described_class.get(restructurer_name)
      expect(type_validator).to eq(ExcelDataServices::Validators::TypeValidity::SacoShipping)
    end
  end

  describe '.type_errors' do
    context 'when data is valid' do
      let(:valid_data_sheet) do
        { sheet_name: 'Europe',
          restructurer_name: 'saco_shipping',
          rows_data: [{ internal: nil,
                        destination_country: 'Iceland/Island',
                        destination_locode: 'ESLPA',
                        destination_hub: 'Las Palmas',
                        terminal: nil,
                        transshipment_via: nil,
                        carrier: 'DAL',
                        origin_locode: 'DE HAM',
                        effective_date: Date.parse('Tue, 23 Jul 2019'),
                        expiration_date: Date.parse('Tue, 23 Jul 2019'),
                        "20dc": Money.new(67_000, :eur),
                        "40dc": 'n/a',
                        "40hq": Money.new(67_000, :eur),
                        "int/ref_nr": 'QHAMA1648',
                        row_nr: 2 }] }
      end

      it 'returns empty array' do
        type_validator_class = described_class.get(valid_data_sheet[:restructurer_name])
        type_validator = type_validator_class.new(sheet: valid_data_sheet)
        expect(type_validator.type_errors).to eq([])
      end
    end

    context 'when data is invalid' do
      let(:invalid_data_sheet) do
        { sheet_name: 'Europe',
          restructurer_name: 'saco_shipping',
          rows_data: [{ internal: nil,
                        origin_locode: 'DHAM',
                        effective_date: '',
                        expiration_date: '',
                        "20dc": Money.new(67_000, :eur),
                        "40dc": 'n/a',
                        "40hq": Money.new(67_000, :eur),
                        "int/ref_nr": 'QHAMA1648',
                        row_nr: 2 }] }
      end

      it 'returns an array of type errors' do
        type_validator_class = described_class.get(invalid_data_sheet[:restructurer_name])
        type_validator = type_validator_class.new(sheet: invalid_data_sheet)
        expect(type_validator.type_errors.count).to eq(3)
      end
    end
  end
end
