# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Route do
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
      FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant)
    ]
  end

  context 'class methods' do
    describe '.detailed_hashes_from_itinerary_ids', :vcr do
      it 'return the route detail hashes' do
        results = described_class.detailed_hashes_from_itinerary_ids([itinerary.id, itinerary_2.id], with_truck_types: { load_type: 'cargo_item' })
        expect(results.is_a?(Hash)).to be_truthy
        expect(results[:route_hashes].length).to eq(1)
        expect(results[:look_ups].keys).to match_array(%w(origin_hub destination_hub origin_nexus destination_nexus))
      end
    end

    describe '.attributes_from_hub_and_itinerary_ids', :vcr do
      it 'return the route detail hashes' do
        results = described_class.attributes_from_hub_and_itinerary_ids(
          Legacy::Stop.where(index: 0).map(&:hub_id),
          Legacy::Stop.where(index: 1).map(&:hub_id),
          [itinerary.id, itinerary_2.id]
        )

        expect(results).to match_array([{ 'itinerary_id' => itinerary.id, 'mode_of_transport' => 'ocean', 'origin_stop_id' => itinerary.stops.first.id, 'destination_stop_id' => itinerary.stops.last.id }])
      end
    end

    describe '.group_data_by_attribute', :vcr do
      it 'return the route detail hashes' do
        routes = [itinerary, itinerary_2].map do |it|
          OfferCalculator::Route.new(
            itinerary_id: it.id,
            origin_stop_id: it.stops.first.id,
            destination_stop_id: it.stops.last.id
          )
        end
        results = described_class.group_data_by_attribute(routes)

        expect(results[:itinerary_ids]).to match_array([itinerary, itinerary_2].map(&:id))
        expect(results[:origin_stop_ids]).to match_array([itinerary, itinerary_2].map { |it| it.first_stop.id })
        expect(results[:destination_stop_ids]).to match_array([itinerary, itinerary_2].map { |it| it.last_stop.id })
      end
    end
  end
end
