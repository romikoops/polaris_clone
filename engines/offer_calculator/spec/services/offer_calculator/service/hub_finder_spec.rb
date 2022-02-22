# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::HubFinder do
  let(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
  let(:scope) { FactoryBot.build(:organizations_scope) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, params: request_params, organization: organization, pre_carriage: true) }
  let(:request_params) do
    FactoryBot.build(:journey_request_params,
      :lcl,
      pickup_address: address,
      destination_hub: destination_hub)
  end
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let!(:common_trucking) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      hub: origin_hub,
      location: trucking_location,
      group_id: group_id)
  end
  let(:trucking_location) { FactoryBot.create(:trucking_location, :zipcode, data: "43813", country: address.country) }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:group_id) { default_group.id }
  let(:results) { described_class.new(request: request).perform }

  before do
    ::Organizations.current_id = organization.id
    allow(request).to receive(:pickup_address).and_return(address)
    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :zipcode)
  end

  describe ".perform" do
    context "with pickup and no delivery" do
      it "returns the correct hub ids", :aggregate_failures do

        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end

    context "with pickup and no delivery and group only truckings" do
      let(:group_id) { group.id }

      it "returns the correct hub ids", :aggregate_failures do
        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end

    context "with LocationGroups" do
      before do
        FactoryBot.create(:pricings_location_group, name: "test", nexus: destination_hub.nexus, organization: organization)
        FactoryBot.create(:pricings_location_group, name: "test", nexus: related_hub.nexus, organization: organization)
      end
      let(:scope) { FactoryBot.build(:organizations_scope, content: {include_location_groups: true}) }
      let(:related_hub) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }

      it "returns related hub with destination hub", :aggregate_failures do
        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub, related_hub])
      end
    end

    context "with LocationGroups but none that match the target Nexus" do
      before do
        FactoryBot.create(:pricings_location_group, name: "test", organization: organization)
      end
      let(:scope) { FactoryBot.build(:organizations_scope, content: {include_location_groups: true}) }

      it "returns related hub with destination hub", :aggregate_failures do
        expect(results[:origin]).to eq([origin_hub])
        expect(results[:destination]).to eq([destination_hub])
      end
    end
  end
end
