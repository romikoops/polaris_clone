# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::MaxDimensions do
  let(:tenant) { create(:tenant) }
  let(:carrier) { create(:carrier, name: 'msc') }
  let(:applicable) { tenant }
  let(:options) { { tenant: tenant, data: input_data, options: {} } }

  before do
    create(:tenant_vehicle, tenant: tenant, name: 'standard', carrier: carrier)
    create(:tenant_vehicle, tenant: tenant, name: 'faster', carrier: carrier)
  end

  describe '.insert' do
    let(:input_data) { build(:excel_data_restructured_max_dimensions) }
    let(:expected_stats) do
      { "legacy/max_dimensions_bundles": { number_created: 2, number_updated: 0, number_deleted: 0 } }
    end

    it 'returns correct stats and creates correct data' do
      stats = described_class.insert(options)
      expect(stats).to eq(expected_stats)
    end
  end
end
