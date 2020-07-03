# frozen_string_literal: true

require 'rails_helper'
require 'roo'

RSpec.describe ExcelDataServices::FileWriters::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:hub) { create(:gothenburg_hub, free_out: false, organization: organization, mandatory_charge: create(:mandatory_charge), nexus: create(:gothenburg_nexus)) }
  let(:result) { described_class.write_document(organization: organization, user: user, file_name: 'test.xlsx', sandbox: nil, options: {}) }
  let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
  let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

  context 'when valid' do
    let(:local_charge_data_without_ranges) do
      local_charge = ::Legacy::LocalCharge.first

      { 'GROUP_ID' => local_charge.group_id,
        'GROUP_NAME' => Groups::Group.find_by(id: local_charge.group_id)&.name,
        'HUB' => 'Gothenburg',
        'COUNTRY' => 'Sweden',
        'EFFECTIVE_DATE' => local_charge.effective_date.strftime('%F'),
        'EXPIRATION_DATE' => local_charge.expiration_date.strftime('%F'),
        'COUNTERPART_HUB' => nil,
        'COUNTERPART_COUNTRY' => nil,
        'SERVICE_LEVEL' => 'standard',
        'CARRIER' => nil,
        'FEE_CODE' => 'SOLAS',
        'FEE' => 'SOLAS',
        'MOT' => 'ocean',
        'LOAD_TYPE' => 'lcl',
        'DIRECTION' => 'export',
        'CURRENCY' => 'EUR',
        'RATE_BASIS' => 'PER_SHIPMENT',
        'MINIMUM' => 17.5,
        'MAXIMUM' => nil,
        'BASE' => nil,
        'TON' => nil,
        'CBM' => nil,
        'KG' => nil,
        'ITEM' => nil,
        'SHIPMENT' => 17.5,
        'BILL' => nil,
        'CONTAINER' => nil,
        'WM' => nil,
        'RANGE_MIN' => nil,
        'RANGE_MAX' => nil,
        'DANGEROUS' => nil }
    end

    context 'without ranges' do
      before do
        create(:legacy_local_charge, hub: hub, organization: organization)
      end

      describe '.perform' do
        it 'writes all local charges to the sheet' do
          aggregate_failures 'testing sheet values' do
            expect(first_sheet.row(1)).to eq(local_charge_data_without_ranges.keys)
            expect(first_sheet.row(2)).to eq(local_charge_data_without_ranges.values)
          end
        end
      end
    end

    context 'with attached group' do
      let(:group) { create(:groups_group, organization: organization, name: 'TEST') }

      before do
        create(:legacy_local_charge, hub: hub, organization: organization, group_id: group.id)
      end

      describe '.perform' do
        it 'writes all local charges to the sheet' do
          aggregate_failures 'testing sheet values' do
            expect(first_sheet.row(1)).to eq(local_charge_data_without_ranges.keys)
            expect(first_sheet.row(2)).to eq(local_charge_data_without_ranges.values)
          end
        end
      end
    end

    context 'with ranges' do
      before do
        create(:local_charge_range, hub: hub, organization: organization)
      end

      let(:local_charge_data_with_ranges) do
        local_charge_with_ranges = ::Legacy::LocalCharge.first

        { 'GROUP_ID' => nil,
          'GROUP_NAME' => nil,
          'HUB' => 'Gothenburg',
          'COUNTRY' => 'Sweden',
          'EFFECTIVE_DATE' => local_charge_with_ranges.effective_date.strftime('%F'),
          'EXPIRATION_DATE' => local_charge_with_ranges.expiration_date.strftime('%F'),
          'COUNTERPART_HUB' => nil,
          'COUNTERPART_COUNTRY' => nil,
          'SERVICE_LEVEL' => 'standard',
          'CARRIER' => nil,
          'FEE_CODE' => 'QDF',
          'FEE' => 'Wharfage / Quay Dues',
          'MOT' => 'ocean',
          'LOAD_TYPE' => 'lcl',
          'DIRECTION' => 'export',
          'CURRENCY' => 'EUR',
          'RATE_BASIS' => 'PER_UNIT_TON_CBM_RANGE',
          'MINIMUM' => 57,
          'MAXIMUM' => nil,
          'BASE' => nil,
          'TON' => 41,
          'CBM' => nil,
          'KG' => nil,
          'ITEM' => nil,
          'SHIPMENT' => nil,
          'BILL' => nil,
          'CONTAINER' => nil,
          'WM' => nil,
          'RANGE_MIN' => 0,
          'RANGE_MAX' => 5,
          'DANGEROUS' => nil }
      end

      describe '.perform' do
        it 'writes all local charges to the sheet' do
          aggregate_failures 'testing sheet values' do
            expect(first_sheet.row(1)).to eq(local_charge_data_with_ranges.keys)
            expect(first_sheet.row(2)).to eq(local_charge_data_with_ranges.values)
          end
        end
      end
    end
  end
end
