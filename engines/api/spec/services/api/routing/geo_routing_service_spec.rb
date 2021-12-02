# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::GeoRoutingService, type: :service do
  include_context "complete_route_with_trucking"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:cargo_classes) { ["lcl"] }
  let(:load_type) { "cargo_item" }
  let(:query) { nil }
  let(:user) { nil }
  let(:result) do
    described_class.nexuses(
      organization: organization,
      coordinates: coordinates,
      query: query,
      load_type: "cargo_item",
      target: target,
      user: user
    )
  end

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
    FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)
  end

  describe ".nexuses" do
    context "when targeting the origin with destination lat lng" do
      let(:coordinates) { { lat: delivery_address.latitude, lng: delivery_address.longitude } }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array(
          Legacy::Itinerary.where(organization: organization).map { |itin| itin.origin_hub.nexus.name }.uniq
        )
      end
    end

    context "when targeting the origin with destination lat lng and groups" do
      let(:coordinates) { { lat: delivery_address.latitude, lng: delivery_address.longitude } }
      let(:target) { :origin_destination }
      let(:user) { FactoryBot.create(:users_client, organization: organization) }

      before do
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: origin_hub,
          location: pickup_trucking_location,
          group: FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
            FactoryBot.create(:groups_membership, member: user, group: tapped_group)
          end)
      end

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array(
          Legacy::Itinerary.where(organization: organization).map { |itin| itin.origin_hub.nexus.name }.uniq
        )
      end
    end

    context "when targeting the origin with destination lat lng and query" do
      let(:coordinates) { { lat: delivery_address.latitude, lng: delivery_address.longitude } }
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

      let(:coordinates) { { lat: delivery_address.latitude, lng: delivery_address.longitude } }
      let(:query) { origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array([origin_hub.nexus.name])
      end
    end

    context "when targeting the destination with origin lat lng" do
      let(:coordinates) { { lat: pickup_address.latitude, lng: pickup_address.longitude } }
      let(:target) { :destination_origin }

      it "Renders a json of destinations for given a origin lat lng" do
        expect(result.pluck(:name)).to match_array(destination_hub.nexus.name)
      end
    end
  end
end
