# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::RouteFinder do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      user: user,
                      tenant: tenant)
  end
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: origin_hub.id),
      destination: Legacy::Hub.where(id: destination_hub.id)
    }
  end
  let(:results) { described_class.new(shipment: shipment).perform(hubs) }

  before do
    FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant)
  end

  describe '.perform', :vcr do
    context 'with success' do
      it 'return the route detail hashes' do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.origin_stop_id).to eq(itinerary.stops.first.id)
          expect(results.first.destination_stop_id).to eq(itinerary.stops.last.id)
        end
      end
    end

    context 'with failure' do
      before do
        allow(OfferCalculator::Route).to receive(:attributes_from_hub_and_itinerary_ids).and_return(nil)
      end

      it 'raises NoRoute when no routes match the query' do
        expect { results }.to raise_error(OfferCalculator::Calculator::NoRoute)
      end
    end
  end
end
