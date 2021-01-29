# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::RoutingService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) {
    FactoryBot.create(:users_client, email: "test@example.com",
                                     password: "veryspeciallysecurehorseradish", organization: organization)
  }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:origin_nexus) { origin_hub.nexus }
  let(:destination_nexus) { destination_hub.nexus }
  let(:default_args) { {organization: organization, load_type: "cargo_item"} }

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, organization_id: organization.id)
    FactoryBot.create(:hamburg_shanghai_itinerary, organization_id: organization.id)
  end

  describe ".nexuses" do
    context "when targeting the origin with query " do
      let(:args) { default_args.merge(target: :origin_destination, query: "Goth") }
      let!(:result) { described_class.nexuses(args) }

      it "Renders a json of origins when query matches origin" do
        expect(result.first.name).to eq(origin_nexus.name)
      end
    end

    context "when targeting the origin with no params " do
      let(:args) { default_args.merge(target: :origin_destination) }
      let!(:result) { described_class.nexuses(args) }

      let(:origins) {
        Legacy::Itinerary.where(organization_id: organization.id).map { |itin| itin.origin_hub.nexus.name }.sort
      }

      it "Renders an array of all origins when location params are empty" do
        expect(result.map(&:name)).to eq(origins)
      end
    end

    context "when targeting the origin with search query" do
      let(:args) { default_args.merge(query: destination_nexus.name[0..2], target: :destination_origin) }
      let!(:result) { described_class.nexuses(args) }

      it "Renders a json of destinations when query matches destination name" do
        expect(result.first.name).to eq(destination_nexus.name)
      end
    end

    context "when targeting the origin with no params" do
      let(:args) { default_args.merge(target: :destination_origin) }
      let!(:result) { described_class.nexuses(args) }

      it "Renders an array of all destinations when location params are empty" do
        expect(result.first.name).to eq(destination_nexus.name)
      end
    end
  end
end
