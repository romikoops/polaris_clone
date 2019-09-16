# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RmsSync::Hubs do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:shanghai) { FactoryBot.create(:shanghai_hub, tenant: tenant) }
  let!(:gothenburg) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  describe '.perform' do
    it 'should create a Book, Sheet and Cells' do
      described_class.new(tenant_id: tenants_tenant.id, sheet_type: :hubs).perform
      expect(RmsData::Book.where(sheet_type: :hubs).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :hubs).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(RmsData::Cell.where(sheet_id: sheet.id).length).to eq(42)
      expect(sheet.rows.length).to eq(3)
      expect(sheet.header_values).to eq(%w(STATUS
                                     TYPE
                                     NAME
                                     CODE
                                     LATITUDE
                                     LONGITUDE
                                     COUNTRY
                                     FULL_ADDRESS
                                     PHOTO
                                     IMPORT_CHARGES
                                     EXPORT_CHARGES
                                     PRE_CARRIAGE
                                     ON_CARRIAGE
                                     ALTERNATIVE_NAMES))
      expect(sheet.row_values(1)).to eq(['active',
                                  'ocean',
                                  'Gothenburg',
                                  'GOO1',
                                  '57.694253',
                                  '11.854048',
                                  'Sweden',
                                  '438 80 Landvetter, Sweden',
                                  nil,
                                  nil,
                                  nil,
                                  nil,
                                  nil,
                                  nil])
    end
  end
end
