# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::HeaderChecker do
  context 'with faulty data' do
    let(:completely_wrong_headers) do
      %i(abc
         def)
    end
    let(:slightly_wrong_headers) do
      %i(efffffffective_date
         expiration_date
         customer_email
         origin
         country_origin
         destination
         country_destination
         mot
         carrier
         service_level
         load_type
         rate_basis
         transit_time
         currency
         bas
         lss
         rate)
    end

    describe '.validate' do
      context 'with completely wrong headers (above threshold)' do
        it 'logs the errors' do
          validator = described_class.new('Sheet1', completely_wrong_headers)
          validator.perform
          expect(validator.errors).to eq(
            [{ exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker,
               reason: 'The type of the data sheet could not be determined. Please check if the headers of the sheet are correct.',
               row_nr: 1,
               type: :error }]
          )
        end
      end

      context 'with slightly wrong headers (below threshold)' do
        it 'logs the errors' do
          validator = described_class.new('Sheet1', slightly_wrong_headers)
          validator.perform
          expect(validator.errors).to eq(
            [{ exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker,
               reason: "The following headers of sheet \"Sheet1\" are not valid:\nCorrect static headers for this sheet are: \"EFFECTIVE_DATE, EXPIRATION_DATE, CUSTOMER_EMAIL, ORIGIN, COUNTRY_ORIGIN, DESTINATION, COUNTRY_DESTINATION, MOT, CARRIER, SERVICE_LEVEL, LOAD_TYPE, RATE_BASIS, TRANSIT_TIME, CURRENCY\",\nMissing static headers are               : \"EFFECTIVE_DATE\",\nUnrecognized static headers are          : \"EFFFFFFFECTIVE_DATE\"",
               row_nr: 1,
               type: :error }]
          )
        end
      end
    end
  end
end
