# frozen_string_literal: true

require "rails_helper"

RSpec.describe Legacy::HubNexusMatchValidator do
  let(:user) { FactoryBot.create(:users_client) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: user.organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle) { FactoryBot.build(:legacy_tenant_vehicle, organization: user.organization) }
  let(:trip) { FactoryBot.build(:legacy_trip, tenant_vehicle: tenant_vehicle) }
  let(:wrong_hub) { FactoryBot.create(:felixstowe_hub, organization: user.organization) }
  let(:args) do
    {
      trip_id: trip.id,
      itinerary_id: itinerary.id,
      organization: user.organization,
      origin_hub_id: origin_hub.id,
      destination_hub_id: destination_hub.id,
      origin_nexus_id: origin_hub.nexus_id,
      destination_nexus_id: destination_hub.nexus_id,
      user: user
    }
  end

  before do
    FactoryBot.create(:legacy_max_dimensions_bundle, organization: user.organization)
    FactoryBot.create(:legacy_max_dimensions_bundle, :aggregated, organization: user.organization)
  end

  it "passes validation" do
    expect(Legacy::Shipment.new(args)).to be_valid
  end

  it "fails validation with the wrong origin hub id" do
    expect(Legacy::Shipment.new(args.merge(origin_hub_id: wrong_hub.id))).to be_invalid
  end
end
