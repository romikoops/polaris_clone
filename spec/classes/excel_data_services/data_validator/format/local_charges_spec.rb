# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidator::Format::LocalCharges do
  let(:klass_identifier) { 'LocalCharges' }
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier } }

  context 'with faulty data' do
    let(:input_data) { build(:excel_data_parsed_faulty_local_charges) }

    describe '.validate' do
      it 'logs the errors' do
        expect(described_class.validate(options)).to eq(
          [
            { reason: "The following headers of sheet \"Sheet1\" are not valid:\n" \
                      "IS       : \"HUBBBBBBBBBBBB\",\nSHOULD BE: \"HUB\"",
              row_nr: 1 },
            { reason: 'Missing value for PER_BILL.', row_nr: 2 }
          ]
        )
      end
    end
  end
end
