# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Validators::RouteHubs do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:mot) { "ocean" }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, hub_type: mot, organization: organization) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, hub_type: mot, organization: organization) }

  before do
    FactoryBot.create(:legacy_itinerary,
      organization: organization,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      mode_of_transport: "ocean")
  end

  describe ".state" do
    shared_examples_for "finding the Origin/Destination hub ids" do
      it "returns the frame with the origin_hub_id && destination_hub_id", :aggregate_failures do
        expect(extracted_table["origin_hub_id"].to_a).to eq([origin_hub.id])
        expect(extracted_table["destination_hub_id"].to_a).to eq([destination_hub.id])
      end
    end

    context "when found via locodes" do
      let(:row) do
        {
          "origin_locode" => origin_hub.hub_code,
          "origin" => nil,
          "country_origin" => nil,
          "destination_locode" => destination_hub.hub_code,
          "destination" => nil,
          "country_destination" => nil,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the Origin/Destination hub ids"
    end

    context "when found via names" do
      let(:row) do
        {
          "origin_locode" => nil,
          "origin" => origin_hub.name,
          "country_origin" => origin_hub.nexus.country.name,
          "destination_locode" => nil,
          "destination" => destination_hub.name,
          "country_destination" => destination_hub.nexus.country.name,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it_behaves_like "finding the Origin/Destination hub ids"
    end

    context "when found via names and terminals" do
      let(:row) do
        {
          "origin_locode" => nil,
          "origin" => origin_hub.name,
          "country_origin" => origin_hub.nexus.country.name,
          "destination_locode" => nil,
          "destination" => destination_hub.name,
          "country_destination" => destination_hub.nexus.country.name,
          "origin_terminal" => nil,
          "destination_terminal" => destination_hub.terminal,
          "mode_of_transport" => "ocean",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end
      let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, hub_type: mot, terminal: "T1", organization: organization) }

      before { FactoryBot.create(:legacy_hub, :shanghai, hub_type: mot, terminal: nil, organization: organization) }

      it_behaves_like "finding the Origin/Destination hub ids"
    end

    context "when no hubs are found" do
      let(:row) do
        {
          "origin_locode" => origin_hub.hub_code,
          "origin" => nil,
          "country_origin" => nil,
          "destination_locode" => destination_hub.hub_code,
          "destination" => nil,
          "country_destination" => nil,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "mode_of_transport" => "air",
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) do
        [
          "The hub '#{origin_hub.hub_code}' cannot be found. Please check that the information is entered correctly",
          "The hub '#{destination_hub.hub_code}' cannot be found. Please check that the information is entered correctly"
        ]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
