# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::TruckingLocation do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    context "when found" do
      let(:zones_rows) do
        [{
          "trucking_location_name" => "20038",
          "country_id" => 709,
          "identifier" => "postal_code",
          "locations_location_id" => "f8fde297-b404-4f8c-9d17-7f0161948aea",
          "query_type" => 1,
          "upsert_id" => "9f7c5890-050c-4349-af32-b63c46a7ab35"
        }]
      end
      let(:expected_data) do
        { "country_id" => 709,
          "location_id" => "f8fde297-b404-4f8c-9d17-7f0161948aea",
          "data" => "20038",
          "identifier" => "postal_code",
          "query" => 1,
          "upsert_id" => "9f7c5890-050c-4349-af32-b63c46a7ab35" }
      end

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a.first).to eq(expected_data)
      end
    end
  end
end
