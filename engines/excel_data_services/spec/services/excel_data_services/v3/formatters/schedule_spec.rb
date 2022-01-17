# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::Schedule do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe ".state" do
    context "when found" do
      let(:row) do
        {   "vessel_name" => "Cap Sud",
            "row" => 1,
            "sheet_name" => "Sheet1",
            "origin_locode" => "DEHAM",
            "destination_locode" => "CNSHA",
            "origin_departure" => Date.parse("Wed, 05 Jan 2022"),
            "destination_arrival" => Date.parse("Sun, 30 Jan 2022"),
            "closing_date" => Date.parse("Sat, 01 Jan 2022"),
            "carrier" => "Hamburg Sud",
            "carrier_code" => "hamburg sud",
            "service" => "standard",
            "mode_of_transport" => "ocean",
            "vessel_code" => "CPSD-11",
            "voyage_code" => "DDFF44-E",
            "organization_id" => organization.id }
      end
      let(:expected_data) do
        [{
          "vessel_name" => "Cap Sud",
          "origin" => "DEHAM",
          "destination" => "CNSHA",
          "origin_departure" => Date.parse("Wed, 05 Jan 2022"),
          "destination_arrival" => Date.parse("Sun, 30 Jan 2022"),
          "closing_date" => Date.parse("Sat, 01 Jan 2022"),
          "carrier" => "Hamburg Sud",
          "service" => "standard",
          "mode_of_transport" => "ocean",
          "vessel_code" => "CPSD-11",
          "voyage_code" => "DDFF44-E",
          "organization_id" => organization.id
        }]
      end

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a).to eq(expected_data)
      end
    end
  end
end
