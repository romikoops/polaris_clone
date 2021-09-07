# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Formatters::Itinerary do
  include_context "for excel_data_services setup"

  describe "#insertable_data" do
    let(:rows) do
      [{ "row" => 1,
         "organization_id" => "b7af2e0e-8e49-435a-9ce8-eadfa3db60b9",
         "origin_locode" => "SEGOT",
         "origin" => nil,
         "country_origin" => nil,
         "destination_locode" => "CNSHA",
         "destination" => nil,
         "country_destination" => nil,
         "mode_of_transport" => "ocean",
         "transshipment" => nil,
         "origin_terminal" => nil,
         "destination_terminal" => nil,
         "origin_hub_id" => 2,
         "origin_name" => "Gothenburg",
         "destination_hub_id" => 3,
         "destination_name" => "Shanghai" },
        { "row" => 2,
          "organization_id" => "b7af2e0e-8e49-435a-9ce8-eadfa3db60b9",
          "origin_locode" => nil,
          "origin" => "Hamburg",
          "country_origin" => "Germany",
          "destination_locode" => nil,
          "destination" => "Shanghai",
          "country_destination" => "China",
          "mode_of_transport" => "ocean",
          "transshipment" => nil,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "origin_hub_id" => 6,
          "origin_name" => "Hamburg",
          "destination_hub_id" => 3,
          "destination_name" => "Shanghai" }]
    end
    let(:expected_data) do
      [
        { "origin_hub_id" => 2,
          "destination_hub_id" => 3,
          "mode_of_transport" => "ocean",
          "transshipment" => nil,
          "organization_id" => "b7af2e0e-8e49-435a-9ce8-eadfa3db60b9",
          "name" => "Gothenburg - Shanghai",
          "upsert_id" => "e412aa83-1fc6-5477-8442-18e26c834fb3" },
        { "origin_hub_id" => 6,
          "destination_hub_id" => 3,
          "mode_of_transport" => "ocean",
          "transshipment" => nil,
          "organization_id" => "b7af2e0e-8e49-435a-9ce8-eadfa3db60b9",
          "name" => "Hamburg - Shanghai",
          "upsert_id" => "d932ac60-6147-5d27-8c3a-4822f5b33019" }
      ]
    end

    let(:service) { described_class.state(state: state_arguments) }

    it "returns the formatted data" do
      expect(service.insertable_data).to match_array(expected_data)
    end
  end
end
