# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::FindByHubIds do
  describe '.perform' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, organization: organization) }

    let(:zipcode)      { '15211' }
    let(:latitude)     { '57.000000' }
    let(:longitude)    { '11.100000' }
    let(:load_type)    { 'cargo_item' }
    let(:carriage)     { 'pre' }
    let(:country_code) { 'SE' }
    let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
    let(:address) do
      FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
    end
    let(:query) { described_class.new(hub_ids: [hub.id], group_id: default_group.id, klass: ::Trucking::Trucking, filters: filters).perform }

    describe '.find_by_hub_id' do
      let(:hub)    { FactoryBot.create(:legacy_hub, :with_lat_lng, organization: organization) }
      let(:tenant_vehicle_name) { 'Test Courier' }
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: tenant_vehicle_name, organization: organization) }

      context 'invalid data' do
        it 'raises an ArgumentError if no hub_id are provided' do
          expect { described_class.new(hub_ids: [], klass: ::Trucking::Trucking) }.to raise_error(ArgumentError)
        end

        it 'returns empty array if no pricings were found' do
          FactoryBot.create(:trucking_trucking,
                            hub: hub,
                            location: FactoryBot.create(:trucking_location, :with_location))
          expect(described_class.new(hub_ids: [-1], klass: ::Trucking::Trucking).perform).to eq([])
        end
      end

      context 'with service name filter' do
        let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '30001') }
        let!(:target) { FactoryBot.create(:trucking_trucking, hub: hub, location: trucking_location, tenant_vehicle: tenant_vehicle, organization: organization) }
        let(:filters) { {courier_name: tenant_vehicle.name} }

        before { FactoryBot.create(:trucking_trucking, hub: hub) }

        it 'finds the correct pricing and destinations', :aggregate_failures do
          expect(query.first).to eq(target)
          expect(query.count).to eq(1)
        end
      end

      context 'with place name filter' do
        let(:trucking_location) { FactoryBot.create(:trucking_location, city_name: 'Shanghai') }
        let!(:target) { FactoryBot.create(:trucking_trucking, hub: hub, location: trucking_location, tenant_vehicle: tenant_vehicle, organization: organization) }
        let(:filters) { {destination: 'Shanghai'} }

        before { FactoryBot.create(:trucking_trucking, hub: hub) }

        it 'finds the correct pricing and destinations', :aggregate_failures do
          expect(query.first).to eq(target)
          expect(query.count).to eq(1)
        end
      end
    end
  end
end
