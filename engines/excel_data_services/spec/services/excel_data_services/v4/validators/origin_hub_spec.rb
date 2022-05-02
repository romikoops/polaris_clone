# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::OriginHub do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:mot) { "ocean" }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, organization: organization) }

  describe ".state" do
    shared_examples_for "finding the Origin hub ids" do
      it "returns the frame with the origin_hub_id" do
        expect(extracted_table["origin_hub_id"].to_a).to eq([origin_hub.id])
      end
    end

    context "when found via locodes" do
      let(:row) do
        {
          "origin_locode" => origin_hub.hub_code,
          "origin_hub" => nil,
          "origin_country" => nil,
          "origin_terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the Origin hub ids"
    end

    context "when found via names" do
      let(:row) do
        {
          "origin_locode" => nil,
          "origin_hub" => origin_hub.name,
          "origin_country" => origin_hub.nexus.country.name,
          "origin_terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the Origin hub ids"
    end

    context "when found via names and terminals" do
      let(:row) do
        {
          "origin_locode" => nil,
          "origin_hub" => origin_hub.name,
          "origin_country" => origin_hub.nexus.country.name,
          "origin_terminal" => origin_hub.terminal,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end
      let(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, terminal: "T1", organization: organization) }

      before { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, terminal: nil, organization: organization) }

      it_behaves_like "finding the Origin hub ids"
    end

    context "when no hubs are found" do
      let(:row) do
        {
          "origin_locode" => origin_hub.hub_code,
          "origin_hub" => nil,
          "origin_country" => nil,
          "origin_terminal" => nil,
          "mode_of_transport" => "air",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) do
        [
          "The origin hub 'SEGOT' cannot be found. Please check that the information is entered correctly"
        ]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
