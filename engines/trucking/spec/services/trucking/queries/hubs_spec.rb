# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::Hubs do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:distance_hub) do
    FactoryBot.create(:legacy_hub,
      latitude: latitude,
      longitude: longitude,
      name: 'Distance',
      organization: organization)
  end
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

  let(:hubs_service) do
    described_class.new(
      organization_id: organization.id, load_type: load_type,
      carriage: carriage, country_code: country_code,
      address: address, cargo_classes: ['lcl'], order_by: 'group_id'
    )
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
        allow(hubs_service).to receive(:calc_distance).and_return(55)
      end

      it 'return empty collection if cargo_class filter does not match any item in db' do
        expect(hubs_service.perform).to match_array([distance_hub, zipcode_hub, location_hub])
      end
    end
  end
end
