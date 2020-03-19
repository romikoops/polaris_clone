# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::RouteFilter do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:carrier) { FactoryBot.create(:legacy_carrier) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, tenant: tenant) }
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
        tenant_vehicle_id: tenant_vehicle.id,
        carrier_id: carrier.id,
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
        shipment.cargo_items.first.update(payload_in_kg: 150_000)
      end

      it 'raises InvalidRoutes when the routes are invalid' do
        expect { described_class.new(shipment: shipment).perform(routes) }.to raise_error(OfferCalculator::Calculator::InvalidRoutes)
      end
    end

    context 'with failure (AggregatedCargo)' do
      before do
        shipment.aggregated_cargo = FactoryBot.create(:legacy_aggregated_cargo, weight: 25_000)
      end

      it 'raises InvalidRoutes when the routes are invalid' do
        expect { described_class.new(shipment: shipment).perform(routes) }.to raise_error(OfferCalculator::Calculator::InvalidRoutes)
      end
    end

    context 'with service specfic max dimensions (success)' do
      before do
        FactoryBot.create(:legacy_cargo_item,
                          dimension_x: 990,
                          dimension_z: 990,
                          dimension_y: 990,
                          payload_in_kg: 10_000,
                          chargeable_weight: 10_000,
                          shipment: shipment)
        FactoryBot.create(:legacy_max_dimensions_bundle,
                          dimension_x: 1000,
                          dimension_z: 1000,
                          dimension_y: 1000,
                          payload_in_kg: 1_000_000,
                          chargeable_weight: 1_000_000,
                          tenant_vehicle_id: tenant_vehicle.id,
                          carrier_id: carrier.id,
                          mode_of_transport: 'ocean',
                          tenant: tenant)
      end

      it 'returns the valid routes' do
        results = described_class.new(shipment: shipment).perform(routes)
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results).to match_array(routes)
        end
      end
    end

    context 'with carrier specfic max dimensions (success)' do
      before do
        FactoryBot.create(:legacy_cargo_item,
                          dimension_x: 990,
                          dimension_z: 990,
                          dimension_y: 990,
                          payload_in_kg: 10_000,
                          chargeable_weight: 10_000,
                          shipment: shipment)
        FactoryBot.create(:legacy_max_dimensions_bundle,
                          dimension_x: 1000,
                          dimension_z: 1000,
                          dimension_y: 1000,
                          payload_in_kg: 1_000_000,
                          chargeable_weight: 1_000_000,
                          tenant_vehicle_id: nil,
                          carrier_id: carrier.id,
                          mode_of_transport: 'ocean',
                          tenant: tenant)
      end

      it 'returns the valid routes' do
        results = described_class.new(shipment: shipment).perform(routes)
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results).to match_array(routes)
        end
      end
    end
  end

  describe '.target_max_dimension' do
    let!(:klass) { described_class.new(shipment: shipment) }
    let(:route) { routes.first }

    before do
      Legacy::MaxDimensionsBundle.destroy_all
    end

    context 'when non aggregate and mot ' do
      let!(:target_mdb) { FactoryBot.create(:legacy_max_dimensions_bundle, tenant: shipment.tenant, aggregate: false, mode_of_transport: route.mode_of_transport) }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: routes.first, aggregate: false)).to eq(target_mdb)
      end
    end

    context 'when  aggregate and mot ' do
      let!(:target_mdb) { FactoryBot.create(:legacy_max_dimensions_bundle, tenant: shipment.tenant, aggregate: true, mode_of_transport: route.mode_of_transport) }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: routes.first, aggregate: true)).to eq(target_mdb)
      end
    end

    context 'when aggregate, mot and tenant_vehicle_id' do
      let!(:target_mdb) { FactoryBot.create(:legacy_max_dimensions_bundle, tenant: shipment.tenant, aggregate: true, mode_of_transport: route.mode_of_transport, tenant_vehicle_id: route.tenant_vehicle_id) }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: routes.first, aggregate: true)).to eq(target_mdb)
      end
    end

    context 'when non aggregate, mot and tenant_vehicle_id' do
      let!(:target_mdb) { FactoryBot.create(:legacy_max_dimensions_bundle, tenant: shipment.tenant, aggregate: false, mode_of_transport: route.mode_of_transport, tenant_vehicle_id: route.tenant_vehicle_id) }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: routes.first, aggregate: false)).to eq(target_mdb)
      end
    end
  end
end
