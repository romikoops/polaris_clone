# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::TruckingPricingFinder do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:membership) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, tenant: tenant) }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, location: trucking_location) }
  let!(:user_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, user_id: user.id, location: trucking_location) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: 'cargo_item', tenant: tenant, user: user, cargo_items: [FactoryBot.create(:legacy_cargo_item)], itinerary: itinerary) }
  let(:address) { FactoryBot.create(:legacy_address) }
  describe '.perform (no base pricing)', :vcr do
    it 'returns a common trucking pricing for the correct hub with no user' do
      service = described_class.new(
        trucking_details: { 'truck_type' => 'default', 'address_id' => address.id },
        address: address,
        carriage: 'pre',
        shipment: shipment,
        user_id: nil,
        sandbox: nil
      )
      results = service.perform(hub.id, 0)
      expect(results['lcl']).to eq(common_trucking)
    end
    it 'returns a common trucking pricing for the correct hub with user' do
      service = described_class.new(
        trucking_details: { 'truck_type' => 'default', 'address_id' => address.id },
        address: address,
        carriage: 'pre',
        shipment: shipment,
        user_id: user.id,
        sandbox: nil
      )
      results = service.perform(hub.id, 0)
      expect(results['lcl']).to eq(user_trucking)
    end
  end
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:user_bp) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let!(:tenants_user) { Tenants::User.find_by(legacy_id: user_bp.id) }
  let!(:group) { FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'Test') }
  let!(:base_pricing_scope) { FactoryBot.create(:tenants_scope, target: tenants_user, content: { base_pricing: true }) }
  let!(:membership) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group) }
  let!(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let!(:group_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, group_id: group.id, location: trucking_location) }
  let!(:shipment_bp) { FactoryBot.create(:legacy_shipment, load_type: 'cargo_item', tenant: tenant, user: user_bp, cargo_items: [FactoryBot.create(:legacy_cargo_item)], itinerary: itinerary) }
  let!(:address_bp) { FactoryBot.create(:legacy_address) }
  describe '.perform (base pricing)', :vcr do
    it 'returns a common trucking pricing for the correct hub with no group' do
      service = described_class.new(
        trucking_details: { 'truck_type' => 'default', 'address_id' => address.id },
        address: address_bp,
        carriage: 'pre',
        shipment: shipment_bp,
        user_id: nil,
        sandbox: nil
      )
      results = service.perform(hub.id, 0)
      expect(results['lcl']).to eq(common_trucking)
    end
    it 'returns a common trucking pricing for the correct hub with user' do
      service = described_class.new(
        trucking_details: { 'truck_type' => 'default', 'address_id' => address.id },
        address: address_bp,
        carriage: 'pre',
        shipment: shipment_bp,
        user_id: user_bp.id,
        sandbox: nil
      )
      results = service.perform(hub.id, 0)
      expect(results['lcl']).to eq(group_trucking)
    end
  end
end
