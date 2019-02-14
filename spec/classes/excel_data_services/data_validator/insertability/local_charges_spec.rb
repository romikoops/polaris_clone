# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidator::Insertability::LocalCharges do
  let(:klass_identifier) { 'LocalCharges' }
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier } }
  let!(:hubs) { [create(:hub, name: 'Bremerhaven Port', tenant: tenant)] }
  let!(:local_charges) do
    [
      create(
        :local_charge,
        tenant: tenant,
        hub: hubs.first,
        tenant_vehicle: tenant_vehicle,
        mode_of_transport: 'ocean',
        load_type: 'lcl',
        counterpart_hub_id: nil,
        direction: 'export',
        fees: { 'CMP' => { 'key' => 'CMP', 'max' => nil, 'min' => nil, 'name' => 'Compliance Fee', 'value' => 2.7, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT' },
                'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' },
                'ISP' => { 'key' => 'ISP', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 4.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT' },
                'QDF' => { 'key' => 'QDF', 'max' => 125, 'min' => 55, 'ton' => 40, 'name' => 'Quay dues', 'currency' => 'EUR', 'rate_basis' => 'PER_TON' },
                'SOL' => { 'key' => 'SOL', 'max' => nil, 'min' => nil, 'name' => 'SOLAS Fee', 'value' => 7.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT' },
                'ZAP' => { 'key' => 'ZAP', 'max' => nil, 'min' => nil, 'name' => 'Zapp', 'value' => 13, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } },
        dangerous: nil,
        effective_date: Date.parse('Thu, 24 Jan 2019'),
        expiration_date: Date.parse('Fri, 24 Jan 2020'),
        uuid: '1e51dc52-56f4-4abe-9c68-e40839167516'
      )
    ]
  end
  let(:cargo_transport_category) do
    create(:transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:vehicle) do
    create(:vehicle,
           transport_categories: [
             cargo_transport_category
           ],
           tenant_vehicles: [tenant_vehicle])
  end
  let(:tenant_vehicle) { create(:tenant_vehicle, tenant: tenant) }

  context 'with faulty data' do
    let(:input_data) { build(:excel_data_restructured_faulty_local_charges) }

    describe '.validate' do
      it 'logs the errors' do
        expect(described_class.validate(options)).to eq(
          [
            { reason: 'Overlapping effective period. (UUID: 12345-abcde-DIFFERENT!!)', row_nr: nil }
          ]
        )
      end
    end
  end
end
