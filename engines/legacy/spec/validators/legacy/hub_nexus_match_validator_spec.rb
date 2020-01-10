# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legacy::HubNexusMatchValidator do
  let(:args) do
    {
      trip_id: trip.id,
      itinerary_id: itinerary.id,
      tenant: tenant,
      origin_hub_id: origin_hub.id,
      destination_hub_id: destination_hub.id,
      origin_nexus_id: origin_hub.nexus_id,
      destination_nexus_id: destination_hub.nexus_id,
      user: user
    }
  end

  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:tenant_vehicle) { FactoryBot.build(:legacy_tenant_vehicle, tenant: tenant) }
  let(:trip) { FactoryBot.build(:legacy_trip, tenant_vehicle: tenant_vehicle) }
  let(:wrong_hub) { FactoryBot.create(:felixstowe_hub, tenant: tenant) }

  it 'passes validation' do
    expect(Legacy::Shipment.new(args)).to be_valid
  end

  it 'fails validation with the wrong origin hub id' do
    expect(Legacy::Shipment.new(args.merge(origin_hub_id: wrong_hub.id))).to be_invalid
  end
end
