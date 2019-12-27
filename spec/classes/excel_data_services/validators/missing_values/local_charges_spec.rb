# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::MissingValues::LocalCharges do
  let(:tenant) { create(:tenant) }
  let(:validator) { described_class.new(tenant: tenant, sheet_name: 'Sheet1', data: data) }
  let(:data) { build(:excel_data_restructured_faulty_local_charges) }

  describe '.perform' do
    it 'detects unknown rate basis and missing values rate basis' do
      validator.perform
      expect(validator.valid?).to be(false)
      expect(validator.results).to eq(
        [
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis,
            reason: 'Missing value for FEE_CODE.',
            row_nr: '2',
            sheet_name: 'Sheet1',
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis,
            reason: 'The rate basis "PER_WRONG" is unknown.',
            row_nr: '2',
            sheet_name: 'Sheet1',
            type: :error },
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis,
             reason: 'Missing value for CURRENCY.',
             row_nr: '2',
             sheet_name: 'Sheet1',
             type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis,
            reason: 'Missing value for PER_SHIPMENT.',
            row_nr: '2',
            sheet_name: 'Sheet1',
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis,
            reason: 'Missing value for PER_BILL.',
            row_nr: '2',
            sheet_name: 'Sheet1',
            type: :error }
        ]
      )
    end
  end
end
