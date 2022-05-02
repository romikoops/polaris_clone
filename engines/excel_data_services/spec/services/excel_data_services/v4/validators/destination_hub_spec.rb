# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::DestinationHub do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:mot) { "ocean" }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, hub_type: mot, organization: organization) }

  describe ".state" do
    shared_examples_for "finding the Destination hub ids" do
      it "returns the frame with the destination_hub_id", :aggregate_failures do
        expect(extracted_table["destination_hub_id"].to_a).to eq([destination_hub.id])
      end
    end

    context "when found via locodes" do
      let(:row) do
        {
          "destination_locode" => destination_hub.hub_code,
          "destination_hub" => nil,
          "destination_country" => nil,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the Destination hub ids"
    end

    context "when found via names" do
      let(:row) do
        {
          "destination_locode" => nil,
          "destination_hub" => destination_hub.name,
          "destination_country" => destination_hub.nexus.country.name,
          "destination_terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the Destination hub ids"
    end

    context "when found via names and terminals" do
      let(:row) do
        {
          "destination_locode" => nil,
          "destination_hub" => destination_hub.name,
          "destination_country" => destination_hub.nexus.country.name,
          "destination_terminal" => destination_hub.terminal,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end
      let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, hub_type: mot, terminal: "T1", organization: organization) }

      before { FactoryBot.create(:legacy_hub, :shanghai, hub_type: mot, terminal: nil, organization: organization) }

      it_behaves_like "finding the Destination hub ids"
    end

    context "when no hubs are found" do
      let(:row) do
        {
          "destination_locode" => destination_hub.hub_code,
          "destination_hub" => nil,
          "destination_country" => nil,
          "destination_terminal" => nil,
          "mode_of_transport" => "air",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) do
        [
          "The destination hub 'CNSHA' cannot be found. Please check that the information is entered correctly"
        ]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
