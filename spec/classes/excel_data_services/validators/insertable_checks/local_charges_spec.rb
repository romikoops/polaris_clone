# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::InsertableChecks::LocalCharges do
  let(:organization) { create(:organizations_organization) }
  let(:options) { { organization: organization, sheet_name: 'Sheet1', data: input_data } }
  let!(:hubs) { [create(:hub, name: 'Bremerhaven', organization: organization)] }
  let!(:local_charges) do
    [
      create(
        :local_charge,
        organization: organization,
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
        effective_date: Date.parse('Thu, 24 Jan 2019').beginning_of_day,
        expiration_date: Date.parse('Fri, 24 Jan 2020').end_of_day.change(usec: 0)
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
  let(:tenant_vehicle) { create(:tenant_vehicle, organization: organization) }

  context 'with faulty data' do
    let(:input_data) { build(:excel_data_restructured_faulty_local_charges) }

    describe '.validate' do
      it 'logs the errors' do
        validator = described_class.new(options)
        validator.perform

        expect(validator.results).to eq(
          [{ exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "Overlapping effective period.\n (Old is covered by new: [2019-01-24 00:00 - 2020-01-24 23:59] <-> [2019-01-24 00:00 - 2020-01-24 23:59]).",
             row_nr: '2',
             sheet_name: 'Sheet1',
             type: :warning },
           { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: 'Hub "BremerERRORhaven" (Ocean) not found!',
             row_nr: '3',
             sheet_name: 'Sheet1',
             type: :error }]
        )
      end
    end
  end
end
