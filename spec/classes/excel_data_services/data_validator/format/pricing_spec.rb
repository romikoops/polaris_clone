# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidator::Format::Pricing do
  let(:klass_identifier) { 'Pricing' }
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier } }

  context 'with faulty data' do
    let(:input_data) { build(:excel_data_parsed_faulty_pricings) }

    describe '.validate' do
      it 'logs the errors' do
        expect(described_class.validate(options)).to eq(
          [
            { reason: "The following headers of sheet \"Sheet1\" are not valid:\n"\
                      "IS       : \"WROOONG\",\nSHOULD BE: \"LOAD_TYPE\"",
              row_nr: 1 }
          ]
        )
      end
    end
  end
end
