# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::RouteFilter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:carrier) { FactoryBot.create(:legacy_carrier) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      user: user,
                      organization: organization)
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
  let(:results) { described_class.new(shipment: shipment).perform(routes) }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization)
  end

  describe '.perform', :vcr do
    context 'with Max dimensions' do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
        FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
      end

      context 'with success' do
        it 'return the route detail hashes' do
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
          expect {
            described_class.new(shipment: shipment).perform(routes)
          }.to raise_error(OfferCalculator::Calculator::InvalidRoutes)
        end
      end

      context 'with failure (AggregatedCargo)' do
        before do
          shipment.aggregated_cargo = FactoryBot.create(:legacy_aggregated_cargo, weight: 25_000)
        end

        it 'raises InvalidRoutes when the routes are invalid' do
          expect {
            described_class.new(shipment: shipment).perform(routes)
          }.to raise_error(OfferCalculator::Calculator::InvalidRoutes)
        end
      end

      context 'with service specfic max dimensions (success)' do
        before do
          FactoryBot.create(:legacy_cargo_item,
                            width: 990,
                            height: 990,
                            length: 990,
                            payload_in_kg: 10_000,
                            chargeable_weight: 10_000,
                            shipment: shipment)
          FactoryBot.create(:legacy_max_dimensions_bundle,
                            width: 1000,
                            height: 1000,
                            length: 1000,
                            payload_in_kg: 1_000_000,
                            chargeable_weight: 1_000_000,
                            tenant_vehicle_id: tenant_vehicle.id,
                            carrier_id: carrier.id,
                            mode_of_transport: 'ocean',
                            organization: organization)
        end

        it 'returns the valid routes' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context 'with carrier specfic max dimensions (success)' do
        before do
          FactoryBot.create(:legacy_cargo_item,
                            width: 990,
                            height: 990,
                            length: 990,
                            payload_in_kg: 10_000,
                            chargeable_weight: 10_000,
                            shipment: shipment)
          FactoryBot.create(:legacy_max_dimensions_bundle,
                            width: 1000,
                            height: 1000,
                            length: 1000,
                            payload_in_kg: 1_000_000,
                            chargeable_weight: 1_000_000,
                            tenant_vehicle_id: nil,
                            carrier_id: carrier.id,
                            mode_of_transport: 'ocean',
                            organization: organization)
        end

        it 'returns the valid routes' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end

      context 'with route specfic max dimensions (success)' do
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
                            carrier_id: nil,
                            itinerary_id: itinerary.id,
                            mode_of_transport: 'ocean',
                            organization: organization)
        end

        it 'returns the valid routes' do
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results).to match_array(routes)
          end
        end
      end
    end

    context 'when no max dimensions available' do
      before { Legacy::MaxDimensionsBundle.destroy_all }

      it 'passes when no max dimensions exist' do
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

    context 'when non aggregate and mot ' do
      let!(:target_mdb) {
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: shipment.organization,
          aggregate: false,
          mode_of_transport: route.mode_of_transport)
      }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: route, aggregate: false, cargo_class: 'lcl')).to eq(target_mdb)
      end
    end

    context 'when  aggregate and mot ' do
      let!(:target_mdb) {
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: shipment.organization,
          aggregate: true,
          mode_of_transport: route.mode_of_transport)
      }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: route, aggregate: true, cargo_class: 'lcl')).to eq(target_mdb)
      end
    end

    context 'when aggregate, mot and tenant_vehicle_id' do
      let!(:target_mdb) {
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: shipment.organization,
          aggregate: true,
          mode_of_transport: route.mode_of_transport,
          tenant_vehicle_id: route.tenant_vehicle_id)
      }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: route, aggregate: true, cargo_class: 'lcl')).to eq(target_mdb)
      end
    end

    context 'when non aggregate, mot and tenant_vehicle_id' do
      let!(:target_mdb) {
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: shipment.organization,
          aggregate: false,
          mode_of_transport: route.mode_of_transport,
          tenant_vehicle_id: route.tenant_vehicle_id)
      }

      it 'finds the corrrect max dimension for the mot' do
        expect(klass.send(:target_max_dimension, route: route, aggregate: false, cargo_class: 'lcl')).to eq(target_mdb)
      end
    end
  end
end
