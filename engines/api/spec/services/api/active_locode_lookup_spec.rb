# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe ActiveLocodeLookup, type: :service do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:result) { described_class.new.perform }
    let(:gothenburg_shanghai_itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, organization: organization) }
    let(:hamburg_shanghai_itinerary) { FactoryBot.create(:legacy_itinerary, :hamburg_shanghai, organization: organization) }
    let(:shanghai_felixstowe_itinerary) { FactoryBot.create(:legacy_itinerary, :shanghai_felixstowe, organization: organization) }

    before do
      FactoryBot.create(:pricings_pricing, itinerary: gothenburg_shanghai_itinerary, organization: organization)
      FactoryBot.create(:pricings_pricing, itinerary: hamburg_shanghai_itinerary, organization: organization)
      FactoryBot.create(:pricings_pricing, itinerary: shanghai_felixstowe_itinerary, organization: organization)
      FactoryBot.create(:legacy_nexus, locode: "AAAAA", organization: organization)
      FactoryBot.create(:legacy_nexus, locode: "BBBBB")
      Organizations.current_id = organization.id
    end

    describe "#perform" do
      it "marks the ports with rates arriving in them as 'import:true'", :aggregate_failures do
        expect(result.dig("CNSHA", :import)).to eq(true)
      end

      it "marks the ports with rates departing from them as 'export:true'", :aggregate_failures do
        expect(result.dig("CNSHA", :export)).to eq(true)
        expect(result.dig("DEHAM", :export)).to eq(true)
        expect(result.dig("SEGOT", :export)).to eq(true)
      end

      it "ignores the ports without rates departing from them" do
        expect(result["AAAA"]).to eq(nil)
      end

      it "ignores the ports without rates arriving in them" do
        expect(result["AAAAA"]).to eq(nil)
      end

      it "ignores Nexuses from other Organizations" do
        expect(result.keys).not_to include("BBBBB")
      end

      context "when there are Nexuses linked by LocationGroups for export" do
        before do
          FactoryBot.create(:pricings_location_group, nexus: Legacy::Nexus.find_by(locode: "AAAAA"), organization: organization, name: "gothenburg")
          FactoryBot.create(:pricings_location_group, nexus: gothenburg_shanghai_itinerary.origin_hub.nexus, organization: organization, name: "gothenburg")
        end

        it "marks the ports related via LocationGroup as having rates" do
          expect(result.dig("AAAAA", :export)).to eq(true)
        end
      end

      context "when there are Nexuses linked by LocationGroups for import" do
        before do
          FactoryBot.create(:pricings_location_group, nexus: Legacy::Nexus.find_by(locode: "AAAAA"), organization: organization, name: "gothenburg")
          FactoryBot.create(:pricings_location_group, nexus: gothenburg_shanghai_itinerary.destination_hub.nexus, organization: organization, name: "gothenburg")
        end

        it "marks the ports related via LocationGroup as having rates" do
          expect(result.dig("AAAAA", :import)).to eq(true)
        end
      end
    end
  end
end
