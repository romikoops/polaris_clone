# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::Hubs do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:distance_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: 'Distance', organization: organization) }
  let(:zipcode_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: 'Zipcode', organization: organization) }
  let(:location_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, name: 'Location', organization: organization) }

  let(:trucking_location_zipcode) { FactoryBot.create(:trucking_location, zipcode: zipcode) }
  let(:trucking_location_geometry)  { FactoryBot.create(:trucking_location, :with_location) }
  let(:trucking_location_distance)  { FactoryBot.create(:trucking_location, distance: distance) }

  let(:zipcode)      { '15211' }
  let(:latitude)     { '57.000000' }
  let(:longitude)    { '11.100000' }
  let(:load_type)    { 'cargo_item' }
  let(:carriage)     { 'pre' }
  let(:distance)     { 55 }
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
                          organization: organization,
                          hub: zipcode_hub,
                          location: trucking_location_zipcode)
        FactoryBot.create(:trucking_trucking,
                          organization: organization,
                          hub: location_hub,
                          location: trucking_location_geometry)
        FactoryBot.create(:trucking_trucking,
                          organization: organization,
                          hub: distance_hub,
                          location: trucking_location_distance)
      end

      it 'return empty collection if cargo_class filter does not match any item in db' do
        hubs = described_class.new(
          klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
          carriage: carriage, country_code: country_code,
          address: address, cargo_classes: ['lcl'], order_by: 'group_id'
        ).perform
        
        expect(hubs).to match_array([distance_hub, zipcode_hub, location_hub])
      end
    end
  end

  describe '.trucking_location_where_statement' do
    let(:klass) do
      described_class.new(
        klass: ::Trucking::Trucking, organization_id: organization.id, load_type: load_type,
        carriage: carriage, country_code: country_code, distance: 20,
        address: address, cargo_classes: ['lcl'], order_by: 'group_id'
      )
    end

    it 'returns the distance in a hash when it exists' do
      expect(klass.trucking_location_where_statement).to eq(trucking_locations: { distance: [20] })
    end
  end
end
