# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::TypeAvailability do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    let(:expected_data) do
      { "carriage" => "pre",
        "load_type" => "cargo_item",
        "truck_type" => "default",
        "country_id" => 709,
        "query_method" => 3 }
    end

    let(:zones_rows) do
      [{
        "row" => 2,
        "zone" => "1.0",
        "identifier" => "postal_code",
        "postal_code" => "20457",
        "country_id" => 709,
        "query_method" => 3,
        "organization_id" => organization.id,
        "sheet_name" => "Zones"
      }]
    end
    let(:rows) do
      [{
        "row" => 2,
        "carriage" => "pre",
        "load_type" => "cargo_item",
        "truck_type" => "default",
        "organization_id" => organization.id,
        "sheet_name" => "Sheet1"
      }]
    end

    it "returns the frame with the insertable_data" do
      expect(insertable_data.to_a.first).to eq(expected_data)
    end
  end
end
