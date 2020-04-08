# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::TruckTypes do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:distance_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: 'Distance Port', tenant: tenant) }
  let(:zipcode_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: 'Zipcode Port', tenant: tenant) }
  let(:location_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: 'Location Port', tenant: tenant) }

  let(:trucking_location_zipcode) { FactoryBot.create(:trucking_location, zipcode: zipcode) }
  let(:trucking_location_geometry)  { FactoryBot.create(:trucking_location, :with_location) }
  let(:trucking_location_distance)  { FactoryBot.create(:trucking_location, distance: distance) }

  let(:zipcode)      { '15211' }
  let(:latitude)     { '57.000000' }
  let(:longitude)    { '11.100000' }
  let(:load_type)    { 'cargo_item' }
  let(:carriage)     { 'pre' }
  let(:distance)     { 179 }
  let(:country_code) { 'SE' }

  let(:address) do
    FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
  end

  before do
    %i[distance location zipcode].each do |query_method|
      FactoryBot.create(:trucking_hub_availability,
                        hub: distance_hub,
                        type_availability: FactoryBot.create(:trucking_type_availability, query_method: query_method))
    end
  end

  describe '.perform' do
    context 'when finding hubs from truckings' do
      before do
        FactoryBot.create(:trucking_trucking,
                          tenant: tenant,
                          hub: zipcode_hub,
                          location: trucking_location_zipcode)
        FactoryBot.create(:trucking_trucking,
                          tenant: tenant,
                          hub: location_hub,
                          location: trucking_location_geometry)
        FactoryBot.create(:trucking_trucking,
                          tenant: tenant,
                          hub: distance_hub,
                          location: trucking_location_distance)
      end

      it 'return empty collection if cargo_class filter does not match any item in db' do
        hubs = described_class.new(
          klass: ::Trucking::Trucking, tenant_id: tenant.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, cargo_classes: ['lcl'], order_by: 'group_id'
        ).perform

        expect(hubs).to match_array(['default'])
      end
    end
  end
end
