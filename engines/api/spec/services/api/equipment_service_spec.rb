# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe EquipmentService, type: :service do
    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
    let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
    let(:itinerary) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: legacy_tenant) }
    let(:fcl_40_hq_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: legacy_tenant) }
    let(:gothenburg) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
    let(:shanghai) { itinerary.hubs.find_by(name: 'Shanghai Port') }
    let(:hamburg) { fcl_40_hq_itinerary.hubs.find_by(name: 'Hamburg Port') }

    before do
      FactoryBot.create(:fcl_20_pricing, tenant: legacy_tenant, itinerary: itinerary)
      FactoryBot.create(:fcl_40_pricing, tenant: legacy_tenant, itinerary: itinerary)
      FactoryBot.create(:fcl_40_hq_pricing, tenant: legacy_tenant, itinerary: fcl_40_hq_itinerary)
    end

    describe '.perform' do
      context 'with no nexus ids' do
        it 'returns all the cargo classes for all itineraries' do
          results = described_class.new(user: user).perform
          expect(results).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
        end
      end

      context 'with origin nexus id' do
        it 'returns all the cargo classes for all itineraries for origin' do
          results = described_class.new(user: user, origin_nexus_id: shanghai.nexus_id).perform
          expect(results).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
        end
      end

      context 'with destination nexus id' do
        it 'returns all the cargo classes for all itineraries for destination' do
          results = described_class.new(user: user, destination_nexus_id: gothenburg.nexus_id).perform
          expect(results).to match_array(%w[fcl_20 fcl_40])
        end
      end

      context 'with origin and destination nexus id' do
        it 'returns all the cargo classes for all itineraries for origin and destination' do
          results = described_class.new(user: user, origin_nexus_id: shanghai.nexus_id, destination_nexus_id: hamburg.nexus_id).perform
          expect(results).to match_array(%w[fcl_40_hq])
        end
      end

      context 'with dedicated_pricings_only' do
        before do
          FactoryBot.create(:tenants_group, tenant: tenant).tap do |tapped_group|
            FactoryBot.create(:tenants_membership, member: user, group: tapped_group)
            FactoryBot.create(:pricings_pricing, tenant: legacy_tenant, group_id: tapped_group.id, cargo_class: 'test', load_type: 'container', itinerary: itinerary)
          end
        end

        it 'returns all the cargo classes for all itineraries with group pricings' do
          results = described_class.new(user: user, dedicated_pricings_only: true).perform
          expect(results).to match_array(%w[test])
        end
      end
    end
  end
end
