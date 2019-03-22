# frozen_string_literal: true

# require 'rails_helper'

# RSpec.describe OfferCalculatorService::TruckingPricingFinder do
#   let(:tenant) { create(:tenant) }
#   let(:hub) { create(:hub, tenant: tenant) }
#   let(:user) { create(:user, tenant: tenant) }
#   let(:trucking_location) { create(:trucking_location, zipcode: '43813') }
#   let!(:common_trucking) { create(:trucking_trucking, tenant: tenant, hub: hub, location: trucking_location) }
#   let!(:user_trucking) { create(:trucking_trucking, tenant: tenant, hub: hub, user_id: user.id, location: trucking_location) }
#   let(:shipment) { create(:shipment, load_type: 'cargo_item', tenant: tenant, user: user) }
#   let(:address) { create(:address) }
#   describe '.perform', :vcr do
#     it 'returns a common trucking pricing for the correct hub with no user' do
#       service = described_class.new(
#         trucking_details: { 'truck_type' => 'default', 'address_id' => address.id },
#         address: address,
#         carriage: 'pre',
#         shipment: shipment,
#         user_id: nil
#       )
#       results = service.perform(hub.id, 0)
#       expect(results.length).to eq(1)
#       expect(results.first).to eq(common_trucking)
#     end
#     it 'returns a common trucking pricing for the correct hub with user' do
#       service = described_class.new(
#         trucking_details: { 'truck_type' => 'default', 'address_id' => address.id },
#         address: address,
#         carriage: 'pre',
#         shipment: shipment,
#         user_id: user.id
#       )
#       results = service.perform(hub.id, 0)
#       expect(results.length).to eq(1)
#       expect(results.first).to eq(user_trucking)
#     end
#   end
# end
