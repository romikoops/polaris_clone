# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::TypeAvailability do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments, target_frame: "default") }
  let(:extracted_table) { result.frame("default") }
  let(:country) { FactoryBot.create(:legacy_country) }
  let(:query_method) { ExcelDataServices::V4::Extractors::QueryMethod::QUERY_METHOD_ENUM["distance"] }
  let(:frames) { { "default" => frame, "zones" => Rover::DataFrame.new([zone_row]), "rates" => Rover::DataFrame.new([rate_row]) } }
  let(:rate_row) { { "sheet_name" => "Sheet1", "zone" => "1.0", "organization_id" => organization.id } }
  let(:zone_row) do
    {
      "country_id" => country.id,
      "query_method" => query_method,
      "zone" => "1.0",
      "organization_id" => organization.id,
      "sheet_name" => "Zones"
    }
  end

  describe ".state" do
    context "when found" do
      before { FactoryBot.create(:trucking_type_availability, :distance, country: country) }

      let(:row) do
        {
          "truck_type" => "default",
          "load_type" => "cargo_item",
          "carriage" => "pre",
          "row" => 2,
          "sheet_name" => "Sheet1",
          "organization_id" => organization.id
        }
      end

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when not found" do
      let(:row) do
        {
          "truck_type" => "default",
          "load_type" => "cargo_item",
          "carriage" => "on",
          "row" => 2,
          "organization_id" => organization.id,
          "sheet_name" => "Sheet1"
        }
      end
      let(:zone_row) do
        {
          "country_id" => "FR",
          "query_method" => query_method,
          "zone" => "1.0",
          "organization_id" => organization.id,
          "sheet_name" => "Zones"
        }
      end

      it "returns an error detailing what is invalid" do
        expect(extracted_table["type_availability_id"].to_a).to eq([nil])
      end
    end
  end
end
