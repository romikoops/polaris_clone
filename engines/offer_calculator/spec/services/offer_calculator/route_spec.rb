# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Route do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:current_etd) { 2.days.from_now }
  let(:lcl_transport_category) { FactoryBot.create(:ocean_lcl) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'First', organization: organization) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'MSC') }
  let(:other_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'bother', organization: organization, carrier: carrier) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, user: user, organization: organization, load_type: 'cargo_item') }
  let(:date_range) { (Time.zone.today..Time.zone.today + 20.days) }

  before do
    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)

    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle, load_type: 'container')
    FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, hub: origin_hub, organization: organization)
    FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_20_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_hq_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary, organization: organization)
  end

  describe '.detailed_hashes_from_itinerary_ids', :vcr do
    it 'return the route detail hashes' do
      results = described_class.detailed_hashes_from_itinerary_ids(
        [itinerary.id, itinerary_2.id], with_truck_types: { load_type: 'cargo_item' }, base_pricing: true
      )
      aggregate_failures do
        expect(results).to be_a(Hash)
        expect(results[:route_hashes].length).to eq(1)
        expect(results[:look_ups].keys).to match_array(%w[origin_hub destination_hub origin_nexus destination_nexus tenant_vehicle_id])
      end
    end
  end

  describe '.attributes_from_hub_and_itinerary_ids', :vcr do
    let(:args) do
      {
        query: {
          origin_hub_ids: Legacy::Stop.where(index: 0).map(&:hub_id),
          destination_hub_ids: Legacy::Stop.where(index: 1).map(&:hub_id)
        },
        shipment: shipment,
        date_range: date_range,
        scope: { base_pricing: true }
      }
    end

    context 'with single route and service level' do
      it 'return the route detail hashes' do
        results = described_class.attributes_from_hub_and_itinerary_ids(args)
        expect(results).to match_array([{ 'tenant_vehicle_id' => tenant_vehicle.id, 'itinerary_id' => itinerary.id, 'mode_of_transport' => 'ocean', 'origin_stop_id' => itinerary.stops.first.id, 'destination_stop_id' => itinerary.stops.last.id, 'carrier_id' => nil }])
      end
    end

    context 'with single route and multiple service levels' do
      before do
        FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: other_tenant_vehicle)
        FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization, tenant_vehicle_id: other_tenant_vehicle.id)
      end

      it 'return the route detail hashes' do
        results = described_class.attributes_from_hub_and_itinerary_ids(args)

        expect(results).to match_array([
                                         { 'tenant_vehicle_id' => tenant_vehicle.id, 'itinerary_id' => itinerary.id, 'mode_of_transport' => 'ocean', 'origin_stop_id' => itinerary.stops.first.id, 'destination_stop_id' => itinerary.stops.last.id, 'carrier_id' => nil },
                                         { 'tenant_vehicle_id' => other_tenant_vehicle.id, 'itinerary_id' => itinerary.id, 'mode_of_transport' => 'ocean', 'origin_stop_id' => itinerary.stops.first.id, 'destination_stop_id' => itinerary.stops.last.id, 'carrier_id' => carrier.id }
                                       ])
      end
    end
  end

  describe '.group_data_by_attribute', :vcr do
    let(:routes) do
      [itinerary, itinerary_2].map do |it|
        described_class.new(
          itinerary_id: it.id,
          origin_stop_id: it.stops.first.id,
          destination_stop_id: it.stops.last.id,
          tenant_vehicle_id: tenant_vehicle.id
        )
      end
    end

    it 'return the route detail hashes' do
      results = described_class.group_data_by_attribute(routes)
      aggregate_failures do
        expect(results[:itinerary_ids]).to match_array([itinerary, itinerary_2].map(&:id))
        expect(results[:origin_stop_ids]).to match_array([itinerary, itinerary_2].map { |it| it.first_stop.id })
        expect(results[:destination_stop_ids]).to match_array([itinerary, itinerary_2].map { |it| it.last_stop.id })
      end
    end
  end
end
