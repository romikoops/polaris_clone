# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Rows::Schedules do
  let(:tenant) { create(:tenant) }
  let(:input_data) do
    {
      from: 'DALIAN',
      to: 'FELIXSTOWE',
      closing_date: '2020/01/01',
      etd: '2020/01/04',
      eta: '2020/02/11',
      transit_time: 38,
      carrier: 'MSC',
      mode_of_transport: 'ocean',
      service_level: 'Standard ',
      vessel: 'Cap San Diego',
      voyage_code: '1010101',
      load_type: 'fcl',
      row_nr: 2
    }
  end
  let(:row) { described_class.new(tenant: tenant, row_data: input_data) }

  describe '.closing_date' do
    it 'returns the wavlue form the row' do
      expect(row.closing_date).to eq('2020/01/01')
    end
  end

  describe '.etd' do
    it 'returns the wavlue form the row' do
      expect(row.etd).to eq('2020/01/04')
    end
  end

  describe '.eta' do
    it 'returns the wavlue form the row' do
      expect(row.eta).to eq('2020/02/11')
    end
  end
end
