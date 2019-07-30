# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RmsSync::Pricings do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:tenant_vehicles) do
    [
      FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant),
      FactoryBot.create(:legacy_tenant_vehicle,
                        name: 'faster',
                        tenant: tenant,
                        carrier: FactoryBot.build(:legacy_carrier, name: 'MSC'))
    ]
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }

  describe '.perform' do
    it 'should create a Book, Sheet and Cells' do
      pricings = []
      tenant_vehicles.each do |tv|
        pricings << FactoryBot.create(:lcl_pricing, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_20_pricing, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_pricing, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_hq_pricing, tenant: tenant, tenant_vehicle: tv)
      end
      described_class.new(tenant_id: tenants_tenant.id, sheet_type: :pricings).perform
      expect(RmsData::Book.where(sheet_type: :pricings).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :pricings).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(RmsData::Cell.where(sheet_id: sheet.id).length).to eq(162)
      expect(sheet.rows.length).to eq(9)
      expect(sheet.headers).to eq(%w(EFFECTIVE_DATE
                                     EXPIRATION_DATE
                                     ORIGIN
                                     COUNTRY_ORIGIN
                                     DESTINATION
                                     COUNTRY_DESTINATION
                                     MOT
                                     CARRIER
                                     SERVICE_LEVEL
                                     LOAD_TYPE
                                     RATE_BASIS
                                     RANGE_MIN
                                     RANGE_MAX
                                     FEE_CODE
                                     FEE_NAME
                                     CURRENCY
                                     FEE_MIN
                                     FEE))
      first_row = sheet.rows.select { |r| r[9] == 'lcl' && r[8] == 'slowly'}.first
      expect(first_row).to eq([pricings.first.effective_date.to_s,
                                  pricings.first.expiration_date.to_s,
                                  'Gothenburg',
                                  'Sweden',
                                  'Gothenburg',
                                  'Sweden',
                                  'ocean',
                                  nil,
                                  'slowly',
                                  'lcl',
                                  'PER_WM',
                                  nil,
                                  nil,
                                  'BAS',
                                  'Basic Ocean Freight',
                                  'EUR',
                                  '1.0',
                                  '25.0'])
    end

    it 'should create multiple rows for range fees' do
      pricing = FactoryBot.create(:lcl_range_pricing, tenant: tenant, tenant_vehicle: tenant_vehicles.first)
      described_class.new(tenant_id: tenants_tenant.id, sheet_type: :pricings).perform
      expect(RmsData::Book.where(sheet_type: :pricings).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :pricings).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(sheet.rows).to eq([%w(EFFECTIVE_DATE
                                   EXPIRATION_DATE
                                   ORIGIN
                                   COUNTRY_ORIGIN
                                   DESTINATION
                                   COUNTRY_DESTINATION
                                   MOT
                                   CARRIER
                                   SERVICE_LEVEL
                                   LOAD_TYPE
                                   RATE_BASIS
                                   RANGE_MIN
                                   RANGE_MAX
                                   FEE_CODE
                                   FEE_NAME
                                   CURRENCY
                                   FEE_MIN
                                   FEE),
                                [pricing.effective_date.to_s,
                                 pricing.expiration_date.to_s,
                                 'Gothenburg',
                                 'Sweden',
                                 'Gothenburg',
                                 'Sweden',
                                 'ocean',
                                 nil,
                                 'slowly',
                                 'lcl',
                                 'PER_KG_RANGE',
                                 '0',
                                 '100',
                                 'BAS',
                                 'Basic Ocean Freight',
                                 'EUR',
                                 '1.0',
                                 '10'],
                                [pricing.effective_date.to_s,
                                 pricing.expiration_date.to_s,
                                 'Gothenburg',
                                 'Sweden',
                                 'Gothenburg',
                                 'Sweden',
                                 'ocean',
                                 nil,
                                 'slowly',
                                 'lcl',
                                 'PER_KG_RANGE',
                                 '101',
                                 '500',
                                 'BAS',
                                 'Basic Ocean Freight',
                                 'EUR',
                                 '1.0',
                                 '8'],
                                [pricing.effective_date.to_s,
                                 pricing.expiration_date.to_s,
                                 'Gothenburg',
                                 'Sweden',
                                 'Gothenburg',
                                 'Sweden',
                                 'ocean',
                                 nil,
                                 'slowly',
                                 'lcl',
                                 'PER_KG_RANGE',
                                 '501',
                                 '1000',
                                 'BAS',
                                 'Basic Ocean Freight',
                                 'EUR',
                                 '1.0',
                                 '6']])
    end
  end
end
