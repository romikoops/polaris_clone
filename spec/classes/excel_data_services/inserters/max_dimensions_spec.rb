# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::MaxDimensions do
  let(:tenant) { create(:tenant) }
  let(:carrier) { create(:carrier, code: 'msc', name: 'msc') }
  let(:applicable) { tenant }
  let(:options) { { tenant: tenant, data: input_data, options: {} } }

  before do
    create(:tenant_vehicle, tenant: tenant, name: 'standard', carrier: carrier)
    create(:tenant_vehicle, tenant: tenant, name: 'faster', carrier: carrier)
  end

  describe '.insert' do
    let(:input_data) { build(:excel_data_restructured_max_dimensions) }

    context 'when successful' do
      let(:expected_stats) do
        { "legacy/max_dimensions_bundles": { number_created: 3, number_updated: 0, number_deleted: 0 }, errors: [] }
      end

      it 'returns correct stats and creates correct data' do
        stats = described_class.insert(options)
        expect(stats).to eq(expected_stats)
      end
    end

    context 'with error' do
      let(:expected_errors) do
        [
          { reason: "Mode of transport can't be blank", row_nr: 2, sheet_name: nil }
        ]
      end
      let(:input_data) do
        [{
          sheet_name: 'Sheet1',
          restructurer_name: 'max_dimensions',
          carrier: 'msc',
          service_level: 'faster',
          mode_of_transport: nil,
          cargo_class: 'fcl_20',
          dimension_x: 0,
          dimension_y: 0,
          dimension_z: 0,
          payload_in_kg: 0.1e6,
          aggregate: false,
          row_nr: 2
        }]
      end
      let(:expected_stats) do
        {
          "legacy/max_dimensions_bundles": { number_created: 0, number_updated: 0, number_deleted: 0 },
          errors: expected_errors,
          has_errors: true
        }
      end

      it 'returns correct stats and creates correct data' do
        stats = described_class.insert(options)
        expect(stats).to eq(expected_stats)
      end
    end
  end
end
