# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::TruckingPricingFinder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:user_bp) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, organization: organization) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let!(:group) { FactoryBot.create(:groups_group, organization: organization, name: 'Test') }
  let!(:group_trucking) { FactoryBot.create(:trucking_trucking, organization: organization, hub: hub, group_id: group.id, location: trucking_location) }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, organization: organization, hub: hub, location: trucking_location) }
  let!(:user_trucking) { FactoryBot.create(:trucking_trucking, organization: organization, hub: hub, user_id: user.id, location: trucking_location) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: 'cargo_item', organization: organization, user: user, cargo_items: [FactoryBot.create(:legacy_cargo_item)], itinerary: itinerary) }
  let(:shipment_bp) { FactoryBot.create(:legacy_shipment, load_type: 'cargo_item', organization: organization, user: user_bp, cargo_items: [FactoryBot.create(:legacy_cargo_item)], itinerary: itinerary) }
  let(:address) { FactoryBot.create(:legacy_address) }
  let!(:address_bp) { FactoryBot.create(:legacy_address) }

  before do
    ::Organizations.current_id = organization.id

    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
  end

  describe '.perform (base pricing)', :vcr do
    before do
      FactoryBot.create(:lcl_pre_carriage_availability, hub: hub, query_type: :zipcode)
      FactoryBot.create(:groups_membership, member: user, group: group)
    end

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
        user_id: user.id,
        sandbox: nil
      )
      results = service.perform(hub.id, 0)
      expect(results['lcl']).to eq(group_trucking)
    end
  end
end
