# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Queries:: ValidRoutes do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
  let(:origin_hub_1) { itinerary.hubs.find_by(name: 'Gothenburg') }
  let(:destination_hub_1) { itinerary.hubs.find_by(name: 'Shanghai') }
  let(:origin_hub_2) { itinerary_2.hubs.find_by(name: 'Shanghai') }
  let(:destination_hub_2) { itinerary_2.hubs.find_by(name: 'Gothenburg') }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: 'cargo_item', user: user, organization: organization) }
  let(:current_etd) { 2.days.from_now }
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: '1') }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: '2') }
  let(:lcl_transport_category) { FactoryBot.create(:ocean_lcl) }
  let(:scope) { {} }
  let(:args) do
    {
      shipment: shipment,
      date_range: (Time.zone.now...Time.zone.now + 34.days),
      query: {
        origin_hub_ids: [origin_hub_1.id, origin_hub_2.id],
        destination_hub_ids: [destination_hub_1.id, destination_hub_2.id]
      },
      scope: scope
    }
  end

  before do
    FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle_1)
    FactoryBot.create(:legacy_trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle_2)

    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
  end

  describe '.perform', :vcr do

    context 'with base_pricing' do
      before do
        FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle_1)
        FactoryBot.create(:lcl_pricing, itinerary: itinerary_2, organization: organization, tenant_vehicle: tenant_vehicle_2)
        FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization)
        FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization)
        FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization)
      end

      let(:scope) { { base_pricing: true }.with_indifferent_access }

      context 'without carriage' do
        it 'return the valid routes for cargo_item' do
          results = described_class.new(args).perform
          aggregate_failures do
            expect(results.length).to eq(2)
            expect(results.pluck('itinerary_id')).to match_array([itinerary.id, itinerary_2.id])
            expect(results.pluck('tenant_vehicle_id')).to match_array([tenant_vehicle_1.id, tenant_vehicle_2.id])
          end
        end
      end

      context 'with trucking and no local charges' do
        before do
          allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        end

        it 'return the valid routes for cargo_item' do
          results = described_class.new(args).perform
          aggregate_failures do
            expect(results.length).to eq(0)
          end
        end
      end

      context 'with trucking and local charges' do
        before do
          FactoryBot.create(:legacy_local_charge, hub: origin_hub_1, organization: organization, tenant_vehicle: tenant_vehicle_1)
          allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        end

        it 'return the valid routes for cargo_item' do
          results = described_class.new(args).perform
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.pluck('itinerary_id')).to match_array([itinerary.id])
            expect(results.pluck('tenant_vehicle_id')).to match_array([tenant_vehicle_1.id])
          end
        end
      end

      context 'with dedicated_pricings_only' do
        let(:scope) do
          { base_pricing: true, dedicated_pricings_only: true }.with_indifferent_access
        end
        let(:group) do
          FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
            FactoryBot.create(:groups_membership, member: user, group: tapped_group)
          end
        end

        before { FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle_1, group_id: group.id) }

        it 'return the valid routes for cargo_item' do
          results = described_class.new(args).perform
          aggregate_failures do
            expect(results.length).to eq(1)
            expect(results.pluck('itinerary_id')).to match_array([itinerary.id])
            expect(results.pluck('tenant_vehicle_id')).to match_array([tenant_vehicle_1.id])
          end
        end
      end
    end
  end
end
