# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::InsertableChecks::ScheduleGenerator do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, sheet_name: 'Sheet1', data: input_data } }

  before do
    FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant)
    FactoryBot.create(:legacy_carrier, code: 'msc', name: 'MSC')
  end

  context 'with faulty data' do
    let(:input_data) do
      [
        { origin: 'GOTHENBURG',
          destination: 'SHANGHAI',
          carrier: 'NO_NAME',
          service_level: nil,
          transit_time: 38,
          cargo_class: 'container',
          row_nr: 2,
          mode_of_transport: 'ocean',
          ordinals: [4] },
        { origin: 'DALIAN',
          destination: 'FELIXSTOWE',
          carrier: 'MSC',
          service_level: nil,
          transit_time: 38,
          cargo_class: 'container',
          row_nr: 3,
          mode_of_transport: 'ocean',
          ordinals: [4] }
      ].map { |data| ExcelDataServices::Rows::ScheduleGenerator.new(row_data: data, tenant: tenant) }
    end

    describe '.validate' do
      it 'logs the errors' do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to eq(
          [
            { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
              reason: "There exists no carrier called 'NO_NAME'.",
              row_nr: 2,
              sheet_name: 'Sheet1',
              type: :error },
            { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
              reason: "There exists no itinerary called 'DALIAN - FELIXSTOWE'.",
              row_nr: 3,
              sheet_name: 'Sheet1',
              type: :error }
          ]
        )
      end
    end
  end
end
