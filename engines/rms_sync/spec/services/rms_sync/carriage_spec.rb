# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsSync::Carriage do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:hub) { FactoryBot.create(:hamburg_hub, tenant: tenant) }
  let(:courier) { FactoryBot.create(:trucking_courier, name: 'TEST', tenant: tenant) }
  let(:trucking_locations) do
    [
      FactoryBot.create(:trucking_location, zipcode: '12344'),
      FactoryBot.create(:trucking_location, zipcode: '12345'),
      FactoryBot.create(:trucking_location, zipcode: '12346')
    ]
  end
  let!(:truckings) do
    trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, tenant: tenant, hub: hub, courier: courier) 
    end
  end
  let!(:routes) do
    [
      FactoryBot.create(:hamburg_shanghai_route)
    ]
  end

  describe '.perform' do
    it 'creates the carriage' do
      RmsSync::Carriage.new(tenant_id: tenants_tenant.id, sheet_type: :carriage).perform
      book = RmsData::Book.find_by(tenant_id: tenants_tenant.id, sheet_type: :carriage)
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(RmsData::Cell.where(sheet_id: sheet.id).length).to eq(8)
      expect(sheet.rows.length).to eq(4)
      expect(sheet.rows_values).to eq([["DE", "Hamburg Port"], ["12344", "x"], ["12345", "x"], ["12346", "x"]])
    end

  end
end