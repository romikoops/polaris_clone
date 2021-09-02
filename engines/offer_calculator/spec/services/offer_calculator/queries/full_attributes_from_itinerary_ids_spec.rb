# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Queries::FullAttributesFromItineraryIds do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
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

  before do
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_pricing, itinerary: itinerary, organization: organization)
    FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary, organization: organization)
  end

  # rubocop: disable Performance/StringInclude
  describe ".perform", :vcr do
    context "when lcl" do
      it "return the route detail hashes for cargo_item", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(result["itinerary_id"]).to eq(itinerary.id)
        expect(result["origin_hub_id"]).to eq(origin_hub.id)
        expect(result["destination_hub_id"]).to eq(destination_hub.id)
        expect(results).not_to(be_any { |res| res["cargo_classes"].match?(/fcl/) })
      end
    end

    context "when fcl" do
      let(:load_type) { "container" }

      it "return the route detail hashes for cargo_item", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(result["itinerary_id"]).to eq(itinerary.id)
        expect(result["origin_hub_id"]).to eq(origin_hub.id)
        expect(result["destination_hub_id"]).to eq(destination_hub.id)
        expect(results).not_to(be_any { |res| res["cargo_classes"].match?(/lcl/) })
      end
    end

    context "with soft deleted pricing" do
      let!(:first_rate) { itinerary.rates.first }

      it "itinerary rates count is reduced by 1" do
        expect { first_rate.destroy }.to change(itinerary.rates, :count).by(-1)
      end

      it "cargo classes will not have the particular pricing" do
        expect(results).not_to(be_any { |res| res["cargo_classes"].include?(first_rate.cargo_class) })
      end
    end

    context "when deleted pricing is restored" do
      let(:load_type) { "container" }
      let(:first_rate) { itinerary.rates.first }

      before do
        first_rate.destroy
      end

      it "itinerary rates count is increased by 1" do
        expect { first_rate.restore }.to change(itinerary.rates, :count).by(1)
      end
    end

    context "when pricing is expired" do
      let(:load_type) { "container" }

      it "cargo classes will not have the particular pricing" do
        pricing = itinerary.rates.first
        pricing.expiration_date = 2.days.ago
        pricing.save!(validate: false)
        expect(results).not_to(be_any { |res| res["cargo_classes"].include?(pricing.cargo_class) })
      end
    end
  end
  # rubocop: enable Performance/StringInclude
end
