# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Queries:: FullAttributesFromItineraryIds do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let!(:default_trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, hub: origin_hub, tenant: tenant) }
  let(:current_etd) { 2.days.from_now }
  let!(:pricings) do
    [
      FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant)
    ]
  end

  context 'base_pricing' do
    let(:scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true }) }
    describe '.perform', :vcr do
      it 'return the route detail hashes for cargo_item' do
        results = described_class.new(itinerary_ids: [itinerary.id, itinerary_2.id], options: { base_pricing: true, with_truck_types: { load_type: 'cargo_item' } }).perform

        expect(results.length).to eq(1)
        expect(results.first['itinerary_id']).to eq(itinerary.id)
        expect(results.first['origin_hub_id']).to eq(origin_hub.id)
        expect(results.first['destination_hub_id']).to eq(destination_hub.id)
      end

      it 'return the route detail hashes for cargo_item' do
        results = described_class.new(itinerary_ids: [itinerary.id, itinerary_2.id], options: { base_pricing: true, with_truck_types: { load_type: 'container' } }).perform

        expect(results.length).to eq(1)
        expect(results.first['itinerary_id']).to eq(itinerary.id)
        expect(results.first['origin_hub_id']).to eq(origin_hub.id)
        expect(results.first['destination_hub_id']).to eq(destination_hub.id)
      end
    end
  end
end
