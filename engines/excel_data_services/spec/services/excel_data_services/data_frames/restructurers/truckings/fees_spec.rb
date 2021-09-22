# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Restructurers::Truckings::Fees do
  include_context "with standard trucking setup"

  let(:sheet_names) { ["Fees"] }
  let(:input_rows) do
    [
      {
        "fee" => "Fuel Surcharge",
        "mot" => "truck_carriage",
        "fee_code" => "FSC",
        "truck_type" => "default",
        "direction" => "export",
        "carriage" => "pre",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 130.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "range_min" => nil,
        "range_max" => nil,
        "carrier" => nil,
        "service" => nil,
        "zone" => "1.0",
        "cargo_class" => "lcl",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "sheet_name" => "Fees"
      },
      {
        "fee" => "Terminal Handling",
        "mot" => "truck_carriage",
        "fee_code" => "THC",
        "truck_type" => "default",
        "direction" => "export",
        "carriage" => "pre",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 120.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "range_min" => nil,
        "range_max" => nil,
        "carrier" => "IGS",
        "service" => nil,
        "zone" => "1.0",
        "cargo_class" => "lcl",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "sheet_name" => "Fees"
      },
      {
        "fee" => "Pickup Fee",
        "mot" => "truck_carriage",
        "fee_code" => "PUF",
        "truck_type" => "default",
        "direction" => "import",
        "carriage" => "on",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 110.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "range_min" => nil,
        "range_max" => nil,
        "carrier" => "IGS",
        "service" => "standard",
        "zone" => "1.0",
        "cargo_class" => "lcl",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "sheet_name" => "Fees"
      },
      {
        "fee" => "Fuel Surcharge",
        "mot" => "truck_carriage",
        "fee_code" => "FSC",
        "truck_type" => "default",
        "direction" => "export",
        "carriage" => "pre",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 100.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "range_min" => nil,
        "range_max" => nil,
        "carrier" => "IGS",
        "service" => "standard",
        "zone" => "2.0",
        "cargo_class" => "lcl",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "sheet_name" => "Fees"
      },
      {
        "fee" => "Fuel Surcharge",
        "mot" => "truck_carriage",
        "fee_code" => "FSC",
        "truck_type" => "default",
        "direction" => "import",
        "carriage" => "on",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 100.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "range_min" => nil,
        "range_max" => nil,
        "carrier" => "IGS",
        "service" => "standard",
        "zone" => "2.0",
        "cargo_class" => "lcl",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "sheet_name" => "Fees"
      }
    ]
  end

  let(:expected_result) do
    [{ "fees" =>
      { "FSC" =>
        { "fee" => "Fuel Surcharge",
          "currency" => "EUR",
          "rate_basis" => "PER_SHIPMENT",
          "shipment" => 130.0,
          "key" => "FSC" },
        "THC" =>
        { "fee" => "Terminal Handling",
          "currency" => "EUR",
          "rate_basis" => "PER_SHIPMENT",
          "shipment" => 120.0,
          "key" => "THC" } },
       "zone" => "1.0",
       "tenant_vehicle_id" => tenant_vehicle.id,
       "truck_type" => "default",
       "carriage" => "pre",
       "cargo_class" => "lcl" },
      { "fees" =>
        { "PUF" =>
          { "fee" => "Pickup Fee",
            "currency" => "EUR",
            "rate_basis" => "PER_SHIPMENT",
            "shipment" => 110.0,
            "key" => "PUF" } },
        "zone" => "1.0",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "truck_type" => "default",
        "carriage" => "on",
        "cargo_class" => "lcl" },
      { "fees" =>
        { "FSC" =>
          { "fee" => "Fuel Surcharge",
            "currency" => "EUR",
            "rate_basis" => "PER_SHIPMENT",
            "shipment" => 100.0,
            "key" => "FSC" } },
        "zone" => "2.0",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "truck_type" => "default",
        "carriage" => "pre",
        "cargo_class" => "lcl" },
      { "fees" =>
        { "FSC" =>
          { "fee" => "Fuel Surcharge",
            "currency" => "EUR",
            "rate_basis" => "PER_SHIPMENT",
            "shipment" => 100.0,
            "key" => "FSC" } },
        "zone" => "2.0",
        "tenant_vehicle_id" => tenant_vehicle.id,
        "truck_type" => "default",
        "carriage" => "on",
        "cargo_class" => "lcl" }]
  end

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    let(:input) do
      Rover::DataFrame.new(input_rows)
    end
    let(:result) { described_class.data(frame: input) }

    context "when it is a single sheet" do
      it "returns the frame with the rate data" do
        expect(result.to_a).to match_array(expected_result)
      end
    end

    context "when there are ranges defined in the fees" do
      let(:input_rows) do
        [
          {
            "fee" => "Fuel Surcharge",
            "mot" => "truck_carriage",
            "fee_code" => "FSC",
            "truck_type" => "default",
            "direction" => "export",
            "carriage" => "pre",
            "currency" => "EUR",
            "rate_basis" => "PER_KG_RANGE",
            "ton" => nil,
            "cbm" => nil,
            "kg" => 5,
            "item" => nil,
            "shipment" => nil,
            "bill" => nil,
            "container" => nil,
            "minimum" => nil,
            "wm" => nil,
            "percentage" => nil,
            "range_min" => 0,
            "range_max" => 100,
            "carrier" => nil,
            "service" => nil,
            "zone" => 1.0,
            "cargo_class" => "lcl",
            "tenant_vehicle_id" => tenant_vehicle.id,
            "sheet_name" => "Fees"
          },
          {
            "fee" => "Fuel Surcharge",
            "mot" => "truck_carriage",
            "fee_code" => "FSC",
            "truck_type" => "default",
            "direction" => "export",
            "carriage" => "pre",
            "currency" => "EUR",
            "rate_basis" => "PER_KG_RANGE",
            "ton" => nil,
            "cbm" => nil,
            "kg" => 10,
            "item" => nil,
            "shipment" => nil,
            "bill" => nil,
            "container" => nil,
            "minimum" => nil,
            "wm" => nil,
            "percentage" => nil,
            "range_min" => 100,
            "range_max" => 200,
            "carrier" => "IGS",
            "service" => nil,
            "zone" => 1.0,
            "cargo_class" => "lcl",
            "tenant_vehicle_id" => tenant_vehicle.id,
            "sheet_name" => "Fees"
          }
        ]
      end
      let(:expected_result) do
        [{ "fees" =>
          { "FSC" =>
            { "fee" => "Fuel Surcharge",
              "currency" => "EUR",
              "rate_basis" => "PER_KG_RANGE",
              "kg" => 5,
              "range" => [{ "kg" => 5, "min" => 0, "max" => 100 }, { "kg" => 10, "min" => 100, "max" => 200 }],
              "key" => "FSC" } },
           "zone" => 1.0,
           "tenant_vehicle_id" => tenant_vehicle.id,
           "truck_type" => "default",
           "carriage" => "pre",
           "cargo_class" => "lcl" }]
      end

      it "returns the frame with the range fee properly constructed" do
        expect(result.to_a).to match_array(expected_result)
      end
    end
  end
end
