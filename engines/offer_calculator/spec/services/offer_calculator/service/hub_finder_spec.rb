# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::HubFinder do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: origin_hub, location: trucking_location) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      tenant: tenant,
                      user: user,
                      trip: nil,
                      origin_hub: nil,
                      destination_hub: nil,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      destination_nexus_id: destination_hub.nexus_id,
                      desired_start_date: Date.today + 4.days,
                      cargo_items: [FactoryBot.create(:legacy_cargo_item)],
                      itinerary: itinerary,
                      has_pre_carriage: true)
  end

  context 'class methods' do
    describe '.perform', :vcr do
      it 'returns the correct hub ids' do
        results = described_class.new(shipment: shipment).perform

        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end
  end
end
