# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::MaxDimensions do
  let(:organization) { create(:organizations_organization) }
  let(:carrier) { create(:carrier, code: 'msc', name: 'msc') }
  let(:applicable) { tenant }
  let(:options) { { organization: organization, data: input_data, options: {} } }

  before do
    create(:tenant_vehicle, organization: organization, name: 'standard', carrier: carrier)
    create(:tenant_vehicle, organization: organization, name: 'faster', carrier: carrier)
    create(:gothenburg_shanghai_itinerary, organization: organization)
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
          width: 0,
          length: 0,
          height: 0,
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
