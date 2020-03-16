# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::RouteFinder do
  before do
    FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: false })

    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: 'container')
    FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_fcl_40_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_fcl_40_hq_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
  end

  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, tenant: tenant) }
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
  let(:date_range) { (Time.zone.today..Time.zone.today + 20.days) }
  let(:results) { described_class.new(shipment: shipment).perform(hubs: hubs, date_range: date_range) }

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
