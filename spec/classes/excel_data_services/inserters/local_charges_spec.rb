# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::LocalCharges do
  let(:tenant) { create(:tenant) }
  let!(:hubs) do
    [create(:hub, tenant: tenant, name: 'Bremerhaven Port', hub_type: 'ocean'),
     create(:hub, tenant: tenant, name: 'Antwerp Port', hub_type: 'ocean'),
     create(:hub, tenant: tenant, name: 'Le Havre Port', hub_type: 'ocean')]
  end
  let(:options) { { tenant: tenant, data: input_data, options: {} } }

  describe '.insert' do
    let!(:carriers) {
      [create(:carrier, name: 'SACO Shipping'),
       create(:carrier, name: 'MSC')]
    }
    let!(:tenant_vehicles) do
      [create(:tenant_vehicle, tenant: tenant, carrier: carriers.first),
       create(:tenant_vehicle, tenant: tenant, carrier: carriers.second)]
    end
    let!(:exising_overlapping_local_charge) do
      create(
        :local_charge,
        mode_of_transport: 'ocean',
        load_type: 'lcl',
        hub: hubs.first,
        tenant: tenant,
        tenant_vehicle: tenant_vehicles.first,
        counterpart_hub_id: nil,
        direction: 'export',
        fees: { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } },
        dangerous: nil,
        effective_date: Date.parse('Thu, 24 Jan 2019'),
        expiration_date: Date.parse('Fri, 24 Jan 2020'),
        user_id: nil
      )
    end
    let(:input_data) { build(:excel_data_restructured_correct_local_charges) }
    let(:expected_stats) do
      { local_charges: { number_created: 4, number_updated: 0, number_deleted: 1 } }
    end
    let(:expected_partial_db_data) do
      [
        [DateTime.parse('Thu, 24 Jan 2019 00:00:00'),
         DateTime.parse('Fri, 24 Jan 2020 23:59:59'),
         'ocean',
         'lcl',
         'export',
         { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } }],
        [DateTime.parse('Thu, 24 Jan 2019 00:00:00'),
         DateTime.parse('Fri, 24 Jan 2020 23:59:59'),
         'ocean',
         'lcl',
         'export',
         { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'range' => [{ 'max' => 100, 'min' => 0, 'value' => 20, 'currency' => 'EUR' }], 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } }],
        [DateTime.parse('Thu, 24 Jan 2019 00:00:00'),
         DateTime.parse('Fri, 24 Jan 2020 23:59:59'),
         'ocean',
         'lcl',
         'export',
         { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } }],
        [DateTime.parse('Thu, 24 Jan 2019 00:00:00'),
         DateTime.parse('Fri, 24 Jan 2020 23:59:59'),
         'ocean',
         'lcl',
         'export',
         { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } }]
      ]
    end

    it 'inserts correctly and returns correct stats' do
      stats = described_class.insert(options)
      expect(LocalCharge.all.map { |lc| lc.slice(:effective_date, :expiration_date, :mode_of_transport, :load_type, :direction, :fees).values }).to match_array(expected_partial_db_data)
      expect(stats).to eq(expected_stats)
    end
  end
end
