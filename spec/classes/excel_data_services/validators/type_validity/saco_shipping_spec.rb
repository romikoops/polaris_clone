# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::TypeValidity::SacoShipping do
  describe '.type_errors' do
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

    it 'returns type errors if any for the specified sheet validator' do
      type_validator_class = described_class.get(valid_data_sheet[:restructurer_name])
      type_validator = type_validator_class.new(sheet: valid_data_sheet)
      expect(type_validator.type_errors).to eq([])
    end
  end
end
