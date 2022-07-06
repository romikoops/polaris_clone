# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::TruckingRates do
  include_context "V4 setup"

  let(:result) { described_class.new(data_frame: data_frame).rates }

  describe "#rates" do
    let(:data_frame) do
      Rover::DataFrame.new([
        { "rate_basis_id" => "e46f56e9-3a2c-4d63-b9ec-011778bb9f46",
          "external_code" => "PER_SHIPMENT",
          "organization_id" => organization.id,
          "charge_category_id" => 127,
          "fee_code" => "trucking_lcl",
          "fee_name" => "Trucking rate",
          "sheet_name" => "Sheet1",
          "target_frame" => "rates",
          "rate" => 2.8392e1,
          "range_min" => 0.0,
          "range_max" => 100.0,
          "modifier" => "kg",
          "rate_type" => "trucking_rate",
          "base" => 1.0,
          "mode_of_transport" => "truck_carriage",
          "row_minimum" => "0.0",
          "bracket_minimum" => "0.0",
          "zone" => "1.0",
          "group_id" => nil,
          "hub_id" => 2,
          "rate_basis" => "PER_SHIPMENT",
          "currency" => "EUR",
          "row" => 6 },
        { "rate_basis_id" => "e46f56e9-3a2c-4d63-b9ec-011778bb9f46",
          "external_code" => "PER_SHIPMENT",
          "organization_id" => organization.id,
          "charge_category_id" => 127,
          "fee_code" => "trucking_lcl",
          "fee_name" => "Trucking rate",
          "sheet_name" => "Sheet1",
          "target_frame" => "rates",
          "rate" => 3.549e1,
          "range_min" => 100.0,
          "range_max" => 200.0,
          "modifier" => "kg",
          "rate_type" => "trucking_rate",
          "base" => 1.0,
          "mode_of_transport" => "truck_carriage",
          "row_minimum" => "0.0",
          "bracket_minimum" => "0.0",
          "zone" => "1.0",
          "group_id" => nil,
          "hub_id" => 2,
          "rate_basis" => "PER_SHIPMENT",
          "currency" => "EUR",
          "row" => 6 },
        { "rate_basis_id" => "e46f56e9-3a2c-4d63-b9ec-011778bb9f46",
          "external_code" => "PER_SHIPMENT",
          "organization_id" => organization.id,
          "charge_category_id" => 127,
          "fee_code" => "trucking_lcl",
          "fee_name" => "Trucking rate",
          "sheet_name" => "Sheet1",
          "target_frame" => "rates",
          "rate" => 4.5422e1,
          "range_min" => 200.0,
          "range_max" => 300.0,
          "modifier" => "kg",
          "rate_type" => "trucking_rate",
          "base" => 1.0,
          "mode_of_transport" => "truck_carriage",
          "row_minimum" => "0.0",
          "bracket_minimum" => "0.0",
          "zone" => "1.0",
          "group_id" => nil,
          "hub_id" => 2,
          "rate_basis" => "PER_SHIPMENT",
          "currency" => "EUR",
          "row" => 6 }
      ])
    end
    let(:expected_data) do
      {
        "organization_id" => organization.id,
        "zone" => "1.0",
        "sheet_name" => "Sheet1",
        "rates" =>
          { "kg" =>
            [{ "rate" => { "currency" => "EUR", "rate" => 28.392, "rate_basis" => "PER_SHIPMENT", "base" => 1.0 },
               "min_kg" => 0.0,
               "max_kg" => 100.0,
               "min_value" => 0.0 },
              { "rate" => { "currency" => "EUR", "rate" => 35.49, "rate_basis" => "PER_SHIPMENT", "base" => 1.0 },
                "min_kg" => 100.0,
                "max_kg" => 200.0,
                "min_value" => 0.0 },
              { "rate" => { "currency" => "EUR", "rate" => 45.422, "rate_basis" => "PER_SHIPMENT", "base" => 1.0 },
                "min_kg" => 200.0,
                "max_kg" => 300.0,
                "min_value" => 0.0 }] }
      }
    end

    it "returns the frame with the formatted rates hash" do
      expect(result.to_a.first).to eq(expected_data)
    end
  end
end
