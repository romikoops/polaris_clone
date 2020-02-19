# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::RouteFilter do
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
  let(:routes) do
    [
      OfferCalculator::Route.new(
        itinerary_id: itinerary.id,
        origin_stop_id: itinerary.stops.first.id,
        destination_stop_id: itinerary.stops.last.id,
        mode_of_transport: 'ocean'
      )
    ]
  end

  before do
    FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant)
  end

  describe '.perform', :vcr do
    context 'with success' do
      it 'return the route detail hashes' do
        results = described_class.new(shipment: shipment).perform(routes)
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results).to match_array(routes)
        end
      end
    end

    context 'with failure' do
      before do
        allow(shipment.cargo_items.first).to receive(:valid_for_mode_of_transport?).and_return(false)
      end

      it 'raises InvalidRoutes when the routes are invalid' do
        expect { described_class.new(shipment: shipment).perform(routes) }.to raise_error(OfferCalculator::Calculator::InvalidRoutes)
      end
    end
  end
end
