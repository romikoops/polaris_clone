# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Margins do
  let(:tenant) { create(:tenant) }
  let!(:itineraries) do
    [
      create(:itinerary, tenant: tenant, name: 'Dalian - Gothenburg'),
      create(:itinerary, tenant: tenant, name: 'Ningbo - Gothenburg')
    ]
  end
  let!(:charge_categories) do
    [
      create(:charge_category, :bas, tenant: tenant)
    ]
  end
  let(:carrier) { create(:carrier, name: 'Consolidation') }
  let!(:tenant_vehicle) { create(:tenant_vehicle, tenant: tenant, carrier: carrier) }
  let(:applicable) { tenant }
  let(:options) { { tenant: tenant, data: input_data, options: { applicable: applicable } } }

  describe '.insert' do
    let(:input_data) { build(:excel_data_restructured_correct_margins) }
    let(:expected_stats) do
      { "pricings/margins": { number_created: 1, number_updated: 0, number_deleted: 0 },
        "pricings/details": { number_created: 2, number_updated: 0, number_deleted: 0 } }
    end

    it 'returns correct stats and creates correct data' do
      stats = described_class.insert(options)
      expect(stats).to eq(expected_stats)
    end
  end
end
