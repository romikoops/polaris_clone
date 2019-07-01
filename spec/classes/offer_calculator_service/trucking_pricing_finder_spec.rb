# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculatorService::TruckingPricingFinder do
  let(:tenant) { create(:tenant) }
  let(:hub) { create(:hub, tenant: tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:membership) { create(:tenants_membership, member: tenants_user, group: group) }
  let(:trucking_location) { create(:trucking_location, zipcode: '43813') }
  let!(:common_trucking) { create(:trucking_trucking, tenant: tenant, hub: hub, location: trucking_location) }
  let!(:user_trucking) { create(:trucking_trucking, tenant: tenant, hub: hub, user_id: user.id, location: trucking_location) }
  let(:shipment) { create(:shipment, load_type: 'cargo_item', tenant: tenant, user: user, cargo_items: [create(:cargo_item)]) }
  let(:address) { create(:address) }
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
  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:hub) { create(:hub, tenant: tenant) }
  let(:user_bp) { create(:user, tenant: tenant) }
  let!(:tenants_user) { Tenants::User.find_by(legacy_id: user_bp.id) }
  let!(:group) { create(:tenants_group, tenant: tenants_tenant, name: 'Test') }
  let!(:base_pricing_scope) { create(:tenants_scope, target: tenants_user, content: { base_pricing: true }) }
  let!(:membership) { create(:tenants_membership, member: tenants_user, group: group) }
  let!(:trucking_location) { create(:trucking_location, zipcode: '43813') }
  let!(:group_trucking) { create(:trucking_trucking, tenant: tenant, hub: hub, group_id: group.id, location: trucking_location) }
  let!(:shipment_bp) { create(:shipment, load_type: 'cargo_item', tenant: tenant, user: user_bp, cargo_items: [create(:cargo_item)]) }
  let!(:address_bp) { create(:address) }
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
