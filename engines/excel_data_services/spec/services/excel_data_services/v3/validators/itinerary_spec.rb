# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Validators::Itinerary do
  include_context "V3 setup"

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
          "itinerary_id" => nil
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
          "itinerary_id" => nil
        }
      end

      let(:error_messages) do
        ["The route '#{row['origin']} - #{row['destination']}' cannot be found."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
