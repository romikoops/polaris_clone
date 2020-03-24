# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::Schedules do
  describe '.restructure' do
    let(:tenant) { create(:tenant) }
    let(:data) do
      { sheet_name: 'Sheet1',
        data_restructurer_name: 'schedules',
        rows_data: [
          {
            from: 'DALIAN',
            to: 'FELIXSTOWE',
            closing_date: '2020/01/01',
            etd: '2020/01/04',
            eta: '2020/02/11',
            transit_time: 38,
            carrier: 'MSC',
            service_level: 'Standard ',
            vessel: 'Cap San Diego',
            voyage_code: '1010101',
            load_type: 'fcl',
            row_nr: 2
          },
          {
            from: 'SHANGHAI',
            to: 'FELIXSTOWE',
            closing_date: '2020/01/01',
            etd: '2020/01/04',
            eta: '2020/02/11',
            transit_time: 38,
            carrier: nil,
            service_level: 'EXPRESS ',
            vessel: 'Cap San Marino',
            voyage_code: '101010101',
            load_type: 'lcl',
            row_nr: 3
          }
        ]
      }
    end


    it 'extracts the row data from the sheet hash' do
      result = described_class.restructure(tenant: tenant, data: data)
      result = result['Schedules']
      expect(result.length).to be(2)
      expect(result.pluck(:carrier)).to match_array(['MSC', nil])
      expect(result.pluck(:service_level)).to match_array(['standard', 'express'])
      expect(result.pluck(:load_type)).to match_array(['container', 'cargo_item'])
    end
  end
end
