# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Queries::FullAttributesFromItineraryIds do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, rates: pricings, organization: organization) }
  let(:itinerary2) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:current_etd) { 2.days.from_now }
  let(:load_type) { "cargo_item" }
  let(:results) do
    described_class.new(itinerary_ids: [itinerary.id, itinerary2.id],
                        options: { load_type: load_type }).perform
  end
  let(:result) { results.first }

  let(:pricings) do
    [FactoryBot.build(:lcl_pricing, organization: organization),
      FactoryBot.build(:fcl_20_pricing,  organization: organization),
      FactoryBot.build(:fcl_40_pricing,  organization: organization),
      FactoryBot.build(:fcl_40_hq_pricing, organization: organization)]
  end

  describe ".perform", :vcr do
    context "when lcl" do
      it "return the route detail hashes for cargo_item", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(result["itinerary_id"]).to eq(itinerary.id)
        expect(result["origin_hub_id"]).to eq(origin_hub.id)
        expect(result["destination_hub_id"]).to eq(destination_hub.id)
        expect(results).not_to(be_any { |res| res["cargo_classes"].include?("fcl_20") })
      end
    end

    context "when fcl" do
      let(:load_type) { "container" }

      it "return the route detail hashes for cargo_item", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(result["itinerary_id"]).to eq(itinerary.id)
        expect(result["origin_hub_id"]).to eq(origin_hub.id)
        expect(result["destination_hub_id"]).to eq(destination_hub.id)
        expect(results).not_to(be_any { |res| res["cargo_classes"].include?("lcl") })
      end
    end

    context "with soft deleted pricing" do
      let(:load_type) { "container" }
      let(:pricings) do
        [
          FactoryBot.build(:fcl_40_pricing, organization: organization),
          FactoryBot.build(:fcl_20_pricing, organization: organization, deleted_at: 2.days.ago)
        ]
      end

      it "cargo classes will not have the particular pricing" do
        expect(results).not_to(be_any { |res| res["cargo_classes"].include?("fcl_20") })
      end
    end

    context "when pricing is expired" do
      let(:load_type) { "container" }
      let(:pricings) do
        [
          FactoryBot.build(:fcl_40_pricing, organization: organization),
          FactoryBot.build(:fcl_20_pricing, organization: organization, effective_date: 1.year.ago, expiration_date: 2.days.ago)
        ]
      end

      it "cargo classes will not have the particular pricing" do
        expect(results).not_to(be_any { |res| res["cargo_classes"].include?("fcl_20") })
      end
    end
  end
end
