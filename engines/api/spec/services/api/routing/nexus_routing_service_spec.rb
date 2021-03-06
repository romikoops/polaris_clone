# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::NexusRoutingService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) do
    FactoryBot.create(:users_client, email: "test@example.com",
                                     password: "veryspeciallysecurehorseradish", organization: organization)
  end
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:query) { nil }
  let(:result) do
    described_class.nexuses(
      organization: organization,
      query: query,
      nexus_id: nexus_id,
      load_type: "cargo_item",
      target: target
    )
  end

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization)
    FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)
  end

  describe ".nexuses" do
    context "when targeting the origin with destination id" do
      let(:nexus_id) { itinerary.destination_hub.nexus_id }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination id" do
        expect(result.pluck(:name)).to match_array(
          Legacy::Itinerary.where(organization_id: organization.id).map { |itin| itin.origin_hub.nexus.name }.sort
        )
      end
    end

    context "when targeting the origin with query " do
      let(:target) { :origin_destination }
      let(:query) { itinerary.origin_hub.name.first(4) }
      let(:nexus_id) { itinerary.destination_hub.nexus_id }

      it "Renders a json of origins when query matches origin" do
        expect(result.first.name).to eq(itinerary.origin_hub.nexus.name)
      end
    end

    context "when targeting the origin with destination id and query and multiple hubs" do
      before do
        hub_name = "#{itinerary.origin_hub.name} Airport"
        FactoryBot.create(:legacy_hub, name: hub_name, hub_type: "air", nexus: itinerary.origin_hub.nexus)
      end

      let(:nexus_id) { itinerary.destination_hub.nexus_id }
      let(:query) { itinerary.origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it "Renders a json of origins for given a destination lat lng" do
        expect(result.pluck(:name)).to match_array([itinerary.origin_hub.nexus.name])
      end
    end

    context "when targeting the destination with origin id " do
      let(:target) { :destination_origin }
      let(:nexus_id) { itinerary.origin_hub.nexus_id }

      it "Renders a json of destinations for a given a origin id" do
        expect(result.first.name).to eq(itinerary.destination_hub.nexus.name)
      end
    end

    context "when targeting the destination with search query" do
      let(:target) { :destination_origin }
      let(:query) { itinerary.destination_hub.name.first(4) }
      let(:nexus_id) { itinerary.origin_hub.nexus_id }

      it "Renders a json of destinations when query matches destination name" do
        expect(result.first.name).to eq(itinerary.destination_hub.nexus.name)
      end
    end
  end
end
