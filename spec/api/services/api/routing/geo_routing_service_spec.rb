# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::GeoRoutingService, type: :service do
  include_context "complete_route_with_trucking"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:cargo_classes) { ["lcl"] }
  let(:load_type) { "cargo_item" }
  let(:query) { nil }
  let(:target_user) { nil }
  let(:result) do
    described_class.nexuses(
      organization: organization,
      coordinates: {lat: lat, lng: lng},
      query: query,
      load_type: "cargo_item",
      target: target,
      user: target_user
    )
  end

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
    FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)
  end

  describe ".nexuses" do
    context "when targeting the origin with destination lat lng" do
      let(:expected_results) do
        Legacy::Itinerary.where(organization: organization).map { |itin| itin.first_nexus.name }
      end
      let(:lat) { delivery_address.latitude }
      let(:lng) { delivery_address.longitude }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array(expected_results)
      end
    end

    context "when targeting the origin with destination lat lng and groups" do
      let(:expected_results) do
        Legacy::Itinerary.where(organization: organization).map { |itin| itin.first_nexus.name }
      end
      let(:lat) { delivery_address.latitude }
      let(:lng) { delivery_address.longitude }
      let(:target) { :origin_destination }
      let(:target_user) { user }
      let(:group) {
        FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: user, group: tapped_group)
        end
      }

      before do
        FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub,
                                              location: pickup_trucking_location, group: group)
      end

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array(expected_results)
      end
    end

    context "when targeting the origin with destination lat lng and query" do
      let(:lat) { delivery_address.latitude }
      let(:lng) { delivery_address.longitude }
      let(:query) { origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array([origin_hub.nexus.name])
      end
    end

    context "when targeting the origin with destination lat lng and query and multiple hubs" do
      before do
        FactoryBot.create(:legacy_hub, name: origin_hub.name, hub_type: "air", nexus: origin_hub.nexus)
      end

      let(:lat) { delivery_address.latitude }
      let(:lng) { delivery_address.longitude }
      let(:query) { origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array([origin_hub.nexus.name])
      end
    end

    context "when targeting the destination with origin lat lng" do
      let(:lat) { pickup_address.latitude }
      let(:lng) { pickup_address.longitude }
      let(:target) { :destination_origin }

      it "Renders a json of destinations for given a origin lat lng" do
        expect(result.pluck(:name)).to match_array(destination_hub.nexus.name)
      end
    end
  end
end
