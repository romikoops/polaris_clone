# frozen_string_literal: true

require 'rails_helper'

module Wheelhouse
  RSpec.describe EquipmentService, type: :service do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:itinerary) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
    let(:fcl_40_hq_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, organization: organization) }
    let(:gothenburg) { itinerary.hubs.find_by(name: 'Gothenburg') }
    let(:shanghai) { itinerary.hubs.find_by(name: 'Shanghai') }
    let(:hamburg) { fcl_40_hq_itinerary.hubs.find_by(name: 'Hamburg') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }

    describe '.perform' do
      context "without trucking" do
        before do
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
          FactoryBot.create(:fcl_40_pricing, organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
          FactoryBot.create(:fcl_40_hq_pricing, organization: organization, itinerary: fcl_40_hq_itinerary, tenant_vehicle: tenant_vehicle)
        end

        context 'with no nexus ids' do
          it 'returns all the cargo classes for all itineraries' do
            results = described_class.new(user: user, organization: organization).perform
            expect(results).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
          end
        end

        context 'with origin nexus id' do
          it 'returns all the cargo classes for all itineraries for origin' do
            results = described_class.new(user: user, organization: organization, origin: { nexus_id: shanghai.nexus_id }).perform
            expect(results).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
          end
        end

        context 'with destination nexus id' do
          it 'returns all the cargo classes for all itineraries for destination' do
            results = described_class.new(user: user, organization: organization, destination: { nexus_id: gothenburg.nexus_id }).perform
            expect(results).to match_array(%w[fcl_20 fcl_40])
          end
        end

        context 'with origin and destination nexus id' do
          it 'returns all the cargo classes for all itineraries for origin and destination' do
            results = described_class.new(user: user, organization: organization, origin: { nexus_id: shanghai.nexus_id }, destination: { nexus_id: hamburg.nexus_id }).perform
            expect(results).to match_array(%w[fcl_40_hq])
          end
        end
      end

      context 'with origin and destination lat lngs' do
        include_context "complete_route_with_trucking"
        let(:cargo_classes) { ['fcl_40_hq'] }
        let(:load_type) { 'container' }
        let(:origin) { { latitude: pickup_address.latitude, longitude: pickup_address.longitude } }
        let(:destination) { { latitude: delivery_address.latitude, longitude: delivery_address.longitude } }

        it 'returns all the cargo classes for all itineraries for origin and destination' do
          results = described_class.new(user: user, organization: organization, origin: origin, destination: destination).perform
          expect(results).to match_array(%w[fcl_40_hq])
        end
      end

      context 'with dedicated_pricings_only' do
        before do
          FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
            FactoryBot.create(:groups_membership, member: user, group: tapped_group)
            FactoryBot.create(:pricings_pricing, organization: organization, group_id: tapped_group.id, cargo_class: 'test', load_type: 'container', itinerary: itinerary)
          end
        end

        it 'returns all the cargo classes for all itineraries with group pricings' do
          results = described_class.new(user: user, organization: organization, dedicated_pricings_only: true).perform
          expect(results).to match_array(%w[test])
        end
      end
    end
  end
end
