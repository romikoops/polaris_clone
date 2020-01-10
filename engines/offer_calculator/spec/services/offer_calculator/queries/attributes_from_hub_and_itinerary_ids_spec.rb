# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Queries:: AttributesFromHubAndItineraryIds do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let!(:default_trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, hub: origin_hub, tenant: tenant) }
  let(:current_etd) { 2.days.from_now }
  let!(:legacy_pricings) do
    [
      FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant)
    ]
  end
  let!(:pricings) do
    [
      FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant)
    ]
  end

  context 'legacy' do
    describe '.perform', :vcr do
      it 'return the route detail hashes for cargo_item' do
        args = {
          origin_hub_ids: Legacy::Stop.where(index: 0).map(&:hub_id),
          destination_hub_ids: Legacy::Stop.where(index: 1).map(&:hub_id),
          itinerary_ids: [itinerary.id, itinerary_2.id]
        }
        results = described_class.new(args).perform

        expect(results.length).to eq(1)
        expect(results.first['itinerary_id']).to eq(itinerary.id)
        expect(results.first['origin_stop_id']).to eq(itinerary.stops.find_by(hub_id: origin_hub.id).id)
        expect(results.first['destination_stop_id']).to eq(itinerary.stops.find_by(hub_id: destination_hub.id).id)
      end
    end
  end
end
