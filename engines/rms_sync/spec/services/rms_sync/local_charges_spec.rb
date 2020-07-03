# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RmsSync::LocalCharges do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle,
                      name: 'faster',
                      organization: organization,
                      carrier: FactoryBot.build(:legacy_carrier, name: 'MSC'))
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }

  describe '.perform' do
    it 'should create a Book, Sheet and Cells' do
      local_charge = FactoryBot.create(:legacy_local_charge, organization: organization, tenant_vehicle: tenant_vehicle, mode_of_transport: 'ocean')
      described_class.new(organization_id: organization.id, sheet_type: :local_charges).perform

      expect(RmsData::Book.where(sheet_type: :local_charges).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :local_charges).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(RmsData::Cell.where(sheet_id: sheet.id).length).to eq(58)
      expect(sheet.rows.length).to eq(2)
      expect(sheet.header_values).to eq(%w(HUB
                                           COUNTRY
                                           EFFECTIVE_DATE
                                           EXPIRATION_DATE
                                           COUNTERPART_HUB
                                           COUNTERPART_COUNTRY
                                           SERVICE_LEVEL
                                           CARRIER
                                           FEE_CODE
                                           FEE
                                           MOT
                                           LOAD_TYPE
                                           DIRECTION
                                           CURRENCY
                                           RATE_BASIS
                                           MINIMUM
                                           MAXIMUM
                                           BASE
                                           TON
                                           CBM
                                           KG
                                           ITEM
                                           SHIPMENT
                                           BILL
                                           CONTAINER
                                           WM
                                           RANGE_MIN
                                           RANGE_MAX
                                           DANGEROUS))
      expect(sheet.row_values(1)).to eq([
                                          'Gothenburg',
                                          'Sweden',
                                          local_charge.effective_date.to_s.gsub(' UTC', ''),
                                          local_charge.expiration_date.to_s.gsub(' UTC', ''),
                                          nil,
                                          nil,
                                          'faster',
                                          'MSC',
                                          'SOLAS',
                                          'SOLAS',
                                          'ocean',
                                          'lcl',
                                          'export',
                                          'EUR',
                                          'PER_SHIPMENT',
                                          '17.5',
                                          nil,
                                          nil,
                                          nil,
                                          nil,
                                          nil,
                                          nil,
                                          '17.5',
                                          nil,
                                          nil,
                                          nil,
                                          nil,
                                          nil,
                                          'false'
                                        ])
    end

    it 'should create multiple rows for range fees' do
      local_charge = FactoryBot.create(:local_charge_range, organization: organization, tenant_vehicle: tenant_vehicle)
      described_class.new(organization_id: organization.id, sheet_type: :local_charges).perform
      expect(RmsData::Book.where(sheet_type: :local_charges).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :local_charges).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(sheet.rows_values).to eq([%w(HUB
                                          COUNTRY
                                          EFFECTIVE_DATE
                                          EXPIRATION_DATE
                                          COUNTERPART_HUB
                                          COUNTERPART_COUNTRY
                                          SERVICE_LEVEL
                                          CARRIER
                                          FEE_CODE
                                          FEE
                                          MOT
                                          LOAD_TYPE
                                          DIRECTION
                                          CURRENCY
                                          RATE_BASIS
                                          MINIMUM
                                          MAXIMUM
                                          BASE
                                          TON
                                          CBM
                                          KG
                                          ITEM
                                          SHIPMENT
                                          BILL
                                          CONTAINER
                                          WM
                                          RANGE_MIN
                                          RANGE_MAX
                                          DANGEROUS),
                                       ['Gothenburg',
                                        'Sweden',
                                        local_charge.effective_date.to_s.gsub(' UTC', ''),
                                        local_charge.expiration_date.to_s.gsub(' UTC', ''),
                                        nil,
                                        nil,
                                        'faster',
                                        'MSC',
                                        'QDF',
                                        'Wharfage / Quay Dues',
                                        'ocean',
                                        'lcl',
                                        'export',
                                        'EUR',
                                        'PER_UNIT_TON_CBM_RANGE',
                                        '57',
                                        nil,
                                        nil,
                                        '41',
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        '0',
                                        '5',
                                        'false'],
                                       ['Gothenburg',
                                        'Sweden',
                                        local_charge.effective_date.to_s.gsub(' UTC', ''),
                                        local_charge.expiration_date.to_s.gsub(' UTC', ''),
                                        nil,
                                        nil,
                                        'faster',
                                        'MSC',
                                        'QDF',
                                        'Wharfage / Quay Dues',
                                        'ocean',
                                        'lcl',
                                        'export',
                                        'EUR',
                                        'PER_UNIT_TON_CBM_RANGE',
                                        '57',
                                        nil,
                                        nil,
                                        nil,
                                        '8',
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        nil,
                                        '6',
                                        '40',
                                        'false']])
    end
  end
end
