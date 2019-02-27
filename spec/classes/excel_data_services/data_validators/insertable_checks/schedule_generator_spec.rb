# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidators::InsertableChecks::ScheduleGenerator do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  context 'with faulty data' do
    let(:input_data) do
      [{ origin: 'DALIAN',
         destination: 'FELIXSTOWE',
         carrier: 'NO_NAME',
         service_level: nil,
         transit_time: 38,
         cargo_class: 'container',
         row_nr: 2,
         ordinals: [4] }]
    end

    describe '.validate' do
      it 'logs the errors' do
        validator = described_class.new(options)
        validator.perform
        expect(validator.errors).to eq(
          [{ exception_class: ExcelDataServices::DataValidators::ValidationErrors::InsertableChecks,
             reason: "There exists no carrier called 'NO_NAME'.",
             row_nr: 2,
             type: :error }]
        )
      end
    end
  end
end
