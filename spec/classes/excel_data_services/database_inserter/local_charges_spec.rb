# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DatabaseInserter::LocalCharges do
  let(:tenant) { create(:tenant) }
  let!(:hubs) { [create(:hub, tenant: tenant, name: 'Bremerhaven Port', hub_type: 'ocean')] }
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier, options: {} } }

  describe '.insert' do
    let(:klass_identifier) { 'LocalCharges' }
    let(:input_data) { build(:excel_data_restructured_correct_local_charges) }

    let(:output_data) do
      { local_charges: { number_created: 1, number_updated: 0 } }
    end

    it 'returns correct stats' do
      stats = described_class.insert(options)
      expect(stats).to eq(output_data)
      expect(LocalCharge.first.slice(:mode_of_transport, :load_type, :direction, :fees, :uuid).values)
        .to eq(['ocean',
                'lcl',
                'export',
                { 'DOC' => { 'key' => 'DOC',
                             'max' => nil,
                             'min' => nil,
                             'name' => 'Documentation',
                             'value' => 20,
                             'currency' => 'EUR',
                             'rate_basis' => 'PER_BILL' } },
                '1e51dc52-56f4-4abe-9c68-e40839167516'])
    end
  end
end
