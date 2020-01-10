# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::LocalCharges do
  let(:tenant) { FactoryBot.create(:tenant) }

  let!(:hub) { create(:gothenburg_hub, free_out: false, tenant: tenant, mandatory_charge: create(:mandatory_charge), nexus: create(:gothenburg_nexus)) }
  let!(:local_charge) { create(:legacy_local_charge, hub: hub, tenant: tenant) }
  let!(:hub_headers) do
    %w[hub
       country
       effective_date
       expiration_date
       counterpart_hub
       counterpart_country
       service_level
       carrier
       fee_code
       fee
       mot
       load_type
       direction
       currency
       rate_basis
       minimum
       maximum
       base
       ton
       cbm
       kg
       item
       shipment
       bill
       container
       wm
       range_min
       range_max
       dangerous].map(&:upcase)
  end
  let!(:local_charge_row) do
    ['Gothenburg',
     'Sweden',
     local_charge.effective_date.strftime('%F'),
     local_charge.expiration_date.strftime('%F'),
     nil,
     nil,
     'standard',
     nil,
     'SOLAS',
     'SOLAS',
     'ocean',
     'lcl',
     'export',
     'EUR',
     'PER_SHIPMENT',
     17.5,
     nil,
     nil,
     nil,
     nil,
     nil,
     nil,
     17.5,
     nil,
     nil,
     nil,
     nil,
     nil,
     nil]
  end
  let(:result) { described_class.write_document(tenant: tenant, file_name: 'test.xlsx') }
  let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
  let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

  context 'when all hubs are valid' do
    describe '.perform' do
      it 'writes all local charges to the sheet' do
        aggregate_failures 'testing sheet values' do
          expect(first_sheet.row(1)).to eq(hub_headers)
          expect(first_sheet.row(2)).to eq(local_charge_row)
        end
      end
    end
  end

  context 'when some hubs are invalid' do
    let!(:hub_2) { create(:shanghai_hub, free_out: false, tenant: tenant, mandatory_charge: create(:mandatory_charge), nexus: create(:shanghai_nexus)) }
    let!(:local_charge_2) { create(:legacy_local_charge, hub: hub_2, tenant: tenant) }

    describe '.perform' do
      it 'writes all valid local charges to the sheet' do
        hub_2.destroy
        aggregate_failures 'testing valid sheet values' do
          expect(first_sheet.row(1)).to eq(hub_headers)
          expect(first_sheet.row(2)).to eq(local_charge_row)
          expect(first_sheet.row(3).compact).to eq([])
        end
      end
    end
  end
end
