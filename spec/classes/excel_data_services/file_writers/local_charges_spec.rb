# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::LocalCharges do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let!(:hub) { create(:gothenburg_hub, free_out: false, tenant: tenant, mandatory_charge: create(:mandatory_charge), nexus: create(:gothenburg_nexus)) }
  let(:local_charge) { create(:legacy_local_charge, hub: hub, tenant: tenant) }
  let!(:local_charge_headers) do
    %w[
      group_id
      group_name
      hub
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
      dangerous
    ].map(&:upcase)
  end
  let!(:local_charge_row) do
    [
      local_charge.group_id,
      Tenants::Group.find_by(id: local_charge.group_id)&.name,
      'Gothenburg',
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
      nil
    ]
  end
  let(:result) { described_class.write_document(tenant: tenant, user: tenants_user, file_name: 'test.xlsx', sandbox: nil, options: {}) }
  let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
  let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

  context 'when all local charges are valid' do
    describe '.perform' do
      it 'writes all local charges to the sheet' do
        aggregate_failures 'testing sheet values' do
          expect(first_sheet.row(1)).to eq(local_charge_headers)
          expect(first_sheet.row(2)).to eq(local_charge_row)
        end
      end
    end
  end

  context 'when all local charges are valid with attached group' do
    let(:group) { create(:tenants_group, tenant: tenants_tenant, name: 'TEST') }
    let(:local_charge) { create(:legacy_local_charge, hub: hub, tenant: tenant, group_id: group.id) }

    describe '.perform' do
      it 'writes all local charges to the sheet' do
        aggregate_failures 'testing sheet values' do
          expect(first_sheet.row(1)).to eq(local_charge_headers)
          expect(first_sheet.row(2)).to eq(local_charge_row)
        end
      end
    end
  end

  context 'when some local charges are invalid' do
    let!(:hub_2) { create(:shanghai_hub, free_out: false, tenant: tenant, mandatory_charge: create(:mandatory_charge), nexus: create(:shanghai_nexus)) }
    let!(:local_charge_2) { create(:legacy_local_charge, hub: hub_2, tenant: tenant) }

    describe '.perform' do
      it 'writes all valid local charges to the sheet' do
        hub_2.destroy
        aggregate_failures 'testing valid sheet values' do
          expect(first_sheet.row(1)).to eq(local_charge_headers)
          expect(first_sheet.row(2)).to eq(local_charge_row)
          expect(first_sheet.row(3).compact).to eq([])
        end
      end
    end
  end
end
