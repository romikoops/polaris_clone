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
  let(:load_type) { 'cargo_item' }
  let(:results) { described_class.new(itinerary_ids: [itinerary.id, itinerary_2.id], options: { load_type: load_type }).perform }
  let(:result) { results.first }

  describe '.perform', :vcr do
    context 'when lcl' do
      it 'return the route detail hashes for cargo_item', :aggregate_failures do
        expect(results.length).to eq(1)
        expect(result['itinerary_id']).to eq(itinerary.id)
        expect(result['origin_hub_id']).to eq(origin_hub.id)
        expect(result['destination_hub_id']).to eq(destination_hub.id)
        expect(results.any? { |res| res['cargo_classes'].match?(/fcl/) }).to be_falsy
      end
    end

    context 'when fcl' do
      let(:load_type) { 'container' }

      it 'return the route detail hashes for cargo_item', :aggregate_failures do
        expect(results.length).to eq(1)
        expect(result['itinerary_id']).to eq(itinerary.id)
        expect(result['origin_hub_id']).to eq(origin_hub.id)
        expect(result['destination_hub_id']).to eq(destination_hub.id)
        expect(results.any? { |res| res['cargo_classes'].match?(/lcl/) }).to be_falsy
      end
    end
  end
end
