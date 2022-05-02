# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Hub do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:mot) { "ocean" }
  let(:hub) { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, organization: organization) }

  describe ".state" do
    shared_examples_for "finding the hub ids" do
      it "returns the frame with the hub_id" do
        expect(extracted_table["hub_id"].to_a).to eq([hub.id])
      end
    end

    shared_examples_for "doesn't find the hub ids" do
      it "returns the frame with no hub_id" do
        expect(extracted_table["hub_id"].to_a).to eq([nil])
      end
    end

    context "when found via locodes" do
      let(:row) do
        {
          "locode" => hub.hub_code,
          "hub" => nil,
          "country" => nil,
          "terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the hub ids"
    end

    context "when found via names" do
      let(:row) do
        {
          "locode" => nil,
          "hub" => hub.name,
          "country" => hub.nexus.country.name,
          "terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the hub ids"
    end

    context "when found via names and terminals" do
      let(:row) do
        {
          "locode" => nil,
          "hub" => hub.name,
          "country" => hub.nexus.country.name,
          "terminal" => hub.terminal,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end
      let(:hub) { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, terminal: "T1", organization: organization) }

      before { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, terminal: nil, organization: organization) }

      it_behaves_like "finding the hub ids"
    end

    context "when no hubs are found" do
      let(:row) do
        {
          "locode" => hub.hub_code,
          "hub" => nil,
          "country" => nil,
          "terminal" => nil,
          "mode_of_transport" => "air",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "doesn't find the hub ids"
    end

    context "when no hubs that match the data exactly are found" do
      let(:row) do
        {
          "locode" => "ABCDE",
          "hub" => hub.name,
          "country" => hub.nexus.country.name,
          "terminal" => nil,
          "mode_of_transport" => "air",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "doesn't find the hub ids"
    end
  end
end
