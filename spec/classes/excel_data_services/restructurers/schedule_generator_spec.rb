# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::ScheduleGenerator do
  describe '.restructure' do
    let(:tenant) { create(:tenant) }
    let(:data) { FactoryBot.build(:excel_data_parsed_schedule_generator).first }

    it 'extracts the row data from the sheet hash' do
      result = described_class.restructure(tenant: tenant, data: data)
      result = result['ScheduleGenerator']
      aggregate_failures do
        expect(result.length).to be(4)
        expect(result.first[:ordinals].length).to eq(1)
        expect(result.first[:ordinals].first).to eq(4)
        expect(result.first[:cargo_class]).to eq('container')
        expect(result.first[:mode_of_transport]).to eq('ocean')
      end
    end
  end
end
