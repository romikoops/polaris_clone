# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelTool::ScheduleOverwriter do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let!(:itinerary) { create(:itinerary, name: 'Felixstowe - Ipswich CFS - Hong Kong') }
  let(:carrier) { create(:carrier, name: 'MSC') }
  let(:tenant_vehicle) { create(:tenant_vehicle, carrier: carrier) }
  let!(:pricing) { create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
  let(:dummy_row_data) do
    (1...10).map do |n|
      {
        vessel: 'VESSEL',
        voyage_code: 'VOYAGE_CODE',
        from: 'Felixstowe - Ipswich CFS',
        to: 'Hong Kong',
        closing_date: Date.today + n.days,
        eta: Date.today + (n + 4).days,
        etd: Date.today + (n + 20).days,
        service_level: 'standard',
        carrier: 'MSC',
        load_type: 'cargo_item'
      }
    end
  end

  describe '.parse' do
    let(:xlsx) { double('xlsx') }
    let(:options) do
      {
        params: { xlsx: file_fixture('excel').join('dummy.xlsx').to_s },
        mot: 'ocean',
        user: user,
        sandbox: nil
      }
    end

    it 'returns successfully' do
      allow(xlsx).to receive(:sheets) { ['Sheet1'] }
      allow(xlsx).to receive(:sheet) { ['Sheet1'] }
      parser = described_class.new(options)
      allow(parser).to receive(:schedules) { dummy_row_data }
      expect(parser.perform).to eq(layovers: { number_created: 0, number_updated: 0 },
                                   trips: { number_created: 0, number_updated: 0 })
    end
  end
end
