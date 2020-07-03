# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Queries:: FullAttributesFromItineraryIds do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let!(:default_trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, hub: origin_hub, organization: organization) }
  let(:current_etd) { 2.days.from_now }
  let!(:pricings) do
    [
      FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization),
      FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization),
      FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization),
      FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization)
    ]
  end

  context 'base_pricing' do
    let(:scope) { FactoryBot.create(:organizations_scope, target: organization, content: { base_pricing: true }) }
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
