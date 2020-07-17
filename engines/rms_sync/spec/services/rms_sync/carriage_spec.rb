# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsSync::Carriage do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:hub_1) { FactoryBot.create(:hamburg_hub, organization: organization) }
  let(:hub_2) { FactoryBot.create(:shanghai_hub, organization: organization) }
  let(:hub_3) { FactoryBot.create(:gothenburg_hub, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'TEST', organization: organization) }
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
      FactoryBot.create(:trucking_trucking, location: tl, organization: organization, hub: hub_1, tenant_vehicle: tenant_vehicle)
    end
    truckings_2 = hub_2_trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, organization: organization, hub: hub_2, tenant_vehicle: tenant_vehicle)
    end
    truckings_3 = hub_3_trucking_locations.map do |tl|
      FactoryBot.create(:trucking_trucking, location: tl, organization: organization, hub: hub_3, tenant_vehicle: tenant_vehicle)
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
      RmsSync::Carriage.new(organization_id: organization.id, sheet_type: :carriage).perform
      book = RmsData::Book.find_by(organization_id: organization.id, sheet_type: :carriage)
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(3)
      city_sheet = book.sheets.find { |sheet| sheet.metadata['modifier'] == 'city_name' }
      postal_sheet = book.sheets.find { |sheet| sheet.metadata['modifier'] == 'zipcode' }
      distance_sheet = book.sheets.find { |sheet| sheet.metadata['modifier'] == 'distance' }
      expect(RmsData::Cell.where(sheet_id: city_sheet.id).length).to eq(4)
      expect(RmsData::Cell.where(sheet_id: postal_sheet.id).length).to eq(8)
      expect(RmsData::Cell.where(sheet_id: distance_sheet.id).length).to eq(8)

      expect(postal_sheet.rows_values).to eq([['DE', 'Hamburg'], %w(12344 x), %w(12345 x), %w(12346 x)])
      expect(city_sheet.rows_values).to eq([['SE', 'Gothenburg'], %w(Gothenburg x)])
      expect(distance_sheet.rows_values).to eq([['CN', 'Shanghai'], %w(120 x), %w(121 x), %w(122 x)])
    end
  end
end
