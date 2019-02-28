# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataRestructurer::ScheduleGenerator do
  describe '.restructure_data' do
    let(:tenant) { create(:tenant) }
    let(:klass_identifier) { 'ScheduleGenerator' }
    let(:data) do
      { 'Sheet1' =>
      { data_extraction_method: 'dynamic_fee_cols_no_ranges',
        rows_data: [{ origin: 'DALIAN', destination: 'FELIXSTOWE', etd_days: 'THURSDAY', transit_time: 38, cargo_class: 'fcl', row_nr: 2 },
                    { origin: 'DALIAN', destination: 'SOUTHAMPTON', etd_days: 'WEDNESDAY', transit_time: 34, cargo_class: 'fcl', row_nr: 3 },
                    { origin: 'YANTIAN', destination: 'FELIXSTOWE', etd_days: 'FRIDAY', transit_time: 29, cargo_class: 'lcl', row_nr: 47 },
                    { origin: 'YANTIAN', destination: 'SOUTHAMPTON', etd_days: 'MONDAY', transit_time: 29, cargo_class: 'lcl', row_nr: 48 }] } }
    end

    it 'extracts the row data from the sheet hash' do
      result = described_class.restructure_data(tenant: tenant, klass_identifier: klass_identifier, data: data)
      expect(result.length).to be(4)
      expect(result.first[:ordinals].length).to be(1)
      expect(result.first[:ordinals].first).to be(4)
      expect(result.first[:cargo_class]).to be('container')
    end
  end
end
