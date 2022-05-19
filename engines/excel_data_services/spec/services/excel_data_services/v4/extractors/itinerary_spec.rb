# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Itinerary do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "origin_hub_id" => itinerary.origin_hub_id,
          "destination_hub_id" => itinerary.destination_hub_id,
          "transshipment" => itinerary.transshipment,
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the itinerary_id" do
        expect(extracted_table["itinerary_id"].to_a).to eq([itinerary.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "origin_hub_id" => nil,
          "destination_hub_id" => nil,
          "transshipment" => nil,
          "origin" => "Gothenburg",
          "destination" => "Shanghai",
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "does not find the record or add a itinerary_id" do
        expect(extracted_table["itinerary_id"].to_a).to eq([nil])
      end
    end

    context "with multiple Organizations" do
      let(:other_itinerary) { FactoryBot.create(:legacy_itinerary) }
      let(:rows) do
        [{
          "origin_hub_id" => itinerary.origin_hub_id,
          "destination_hub_id" => itinerary.destination_hub_id,
          "transshipment" => itinerary.transshipment,
          "row" => 2,
          "organization_id" => organization.id
        },
          {
            "origin_hub_id" => other_itinerary.origin_hub_id,
            "destination_hub_id" => other_itinerary.destination_hub_id,
            "transshipment" => other_itinerary.transshipment,
            "row" => 3,
            "organization_id" => other_itinerary.organization_id
          }]
      end

      it "finds both Itineraries and attaches their ids" do
        expect(extracted_table["itinerary_id"].to_a).to eq([itinerary.id, other_itinerary.id])
      end
    end
  end
end
