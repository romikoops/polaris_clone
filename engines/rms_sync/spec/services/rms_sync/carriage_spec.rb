# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsSync::Carriage do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:hub_1) { FactoryBot.create(:hamburg_hub, tenant: tenant) }
  let(:hub_2) { FactoryBot.create(:shanghai_hub, tenant: tenant) }
  let(:hub_3) { FactoryBot.create(:gothenburg_hub, tenant: tenant) }
  let(:courier) { FactoryBot.create(:trucking_courier, name: 'TEST', tenant: tenant) }
  let(:hub_1_trucking_locations) do
    [
      FactoryBot.create(:trucking_location, zipcode: '12344'),
      FactoryBot.create(:trucking_location, zipcode: '12345'),
      FactoryBot.create(:trucking_location, zipcode: '12346')
    ]
  end
  let(:hub_2_trucking_locations) do
    [
      FactoryBot.create(:trucking_location, distance: 120),
      FactoryBot.create(:trucking_location, distance: 121),
      FactoryBot.create(:trucking_location, distance: 122)
    ]
  end
  let(:hub_3_trucking_locations) do
    [
      FactoryBot.create(:city_location)
    ]
  end
  let!(:truckings) do
    truckings_1 = hub_1_trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, tenant: tenant, hub: hub_1, courier: courier)
    end
    truckings_2 = hub_2_trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, tenant: tenant, hub: hub_2, courier: courier)
    end
    truckings_3 = hub_3_trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, tenant: tenant, hub: hub_3, courier: courier)
    end
    truckings_1 | truckings_2 | truckings_3
  end
  let!(:routes) do
    [
      FactoryBot.create(:freight_route, origin_location: :hamburg, destination_location: :shanghai)
    ]
  end

  describe '.perform' do
    it 'creates the carriage' do
      RmsSync::Carriage.new(tenant_id: tenants_tenant.id, sheet_type: :carriage).perform
      book = RmsData::Book.find_by(tenant_id: tenants_tenant.id, sheet_type: :carriage)
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(3)
      city_sheet = book.sheets.find { |sheet| sheet.metadata['modifier'] == 'city_name' }
      postal_sheet = book.sheets.find { |sheet| sheet.metadata['modifier'] == 'zipcode' }
      distance_sheet = book.sheets.find { |sheet| sheet.metadata['modifier'] == 'distance' }
      expect(RmsData::Cell.where(sheet_id: city_sheet.id).length).to eq(4)
      expect(RmsData::Cell.where(sheet_id: postal_sheet.id).length).to eq(8)
      expect(RmsData::Cell.where(sheet_id: distance_sheet.id).length).to eq(8)

      expect(postal_sheet.rows_values).to eq([['DE', 'Hamburg Port'], %w(12344 x), %w(12345 x), %w(12346 x)])
      expect(city_sheet.rows_values).to eq([['SE', 'Gothenburg Port'], %w(Gothenburg x)])
      expect(distance_sheet.rows_values).to eq([['CN', 'Shanghai Port'], %w(120 x), %w(121 x), %w(122 x)])
    end
  end
end
