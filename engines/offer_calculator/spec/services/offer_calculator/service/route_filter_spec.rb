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
  let!(:pricings) do
    [
      FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant),
      FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant),
    ]
  end
  context 'class methods' do
    describe '.perform', :vcr do
      it 'return the route detail hashes' do
        routes = [
          OfferCalculator::Route.new(
            itinerary_id: itinerary.id,
            origin_stop_id: itinerary.stops.first.id,
            destination_stop_id: itinerary.stops.last.id,
            mode_of_transport: 'ocean'
            )
        ]
        results = described_class.new(shipment: shipment).perform(routes)

        expect(results.length).to eq(1)
        expect(results).to match_array(routes)
      end
    end
  end
end
