# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::Trucking do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    let(:load_meterage) do
      {
        "load_meterage_stackable_type" => "area",
        "load_meterage_non_stackable_type" => "ldm",
        "load_meterage_hard_limit" => false,
        "load_meterage_stackable_limit" => 8.0,
        "load_meterage_non_stackable_limit" => 5.0
      }
    end
    let(:zone_overrides) { {} }
    let(:frames) do
      {
        "default" => Rover::DataFrame.new([{
          "cargo_class" => "lcl",
          "effective_date" => Date.parse("Tue, 01 Sep 2020"),
          "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
          "cbm_ratio" => 250.0,
          "currency" => "EUR",
          "base" => nil,
          "rate_basis" => "PER_SHIPMENT",
          "direction" => "export",
          "carrier" => "Gateway Cargo GmbH",
          "load_type" => "cargo_item",
          "service" => "standard",
          "hub_id" => 1873,
          "group_name" => nil,
          "group_id" => "162587c5-0655-416b-a0be-baf07d04063f",
          "mode_of_transport" => "truck_carriage",
          "tenant_vehicle_id" => 550,
          "carrier_id" => 541,
          "sheet_name" => "Sheet1",
          "carriage" => "pre",
          "truck_type" => "default",
          "validity" => "[#{Date.parse('Tue, 01 Sep 2020')}, #{Date.parse('Fri, 31 Dec 2021')})",
          "organization_id" => organization.id
        }.merge(load_meterage)]),
        "zones" => Rover::DataFrame.new([{
          "identifier" => "postal_code",
          "query_type" => 1,
          "location_id" => nil,
          "locations_location_id" => "f8fde297-b404-4f8c-9d17-7f0161948aea",
          "location_name" => "20038",
          "query_method" => 3,
          "type_availability_id" => "6e0434ee-52dc-4e70-a8e1-9f39c67a53c9",
          "trucking_location_id" => "2547fc53-458b-4614-9d97-aaeec9737ebd",
          "trucking_location_name" => "20038",
          "query" => 1,
          "sheet_name" => "Zones",
          "zone" => "1.0",
          "province" => nil,
          "range" => "20037 - 20039",
          "postal_code" => "20038",
          "locode" => nil,
          "distance" => nil,
          "city" => nil,
          "organization_id" => organization.id
        }.merge(zone_overrides)]),
        "rates" => Rover::DataFrame.new([
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
            "row" => 6 }
        ]),
        "fees" => Rover::DataFrame.new([{
          "rate_basis_id" => "e46f56e9-3a2c-4d63-b9ec-011778bb9f46",
          "rate_basis" => "PER_SHIPMENT",
          "charge_category_id" => 128,
          "fee_code" => "fsc",
          "fee_name" => "Fuel Surcharge Fee",
          "sheet_name" => "Fees",
          "organization_id" => organization.id,
          "row" => 0,
          "rate" => 30.0,
          "range_min" => nil,
          "range_max" => nil,
          "modifier" => nil,
          "rate_type" => "trucking_fee",
          "column" => 0,
          "min" => nil,
          "max" => nil,
          "target_frame" => "fees",
          "carriage" => "pre",
          "truck_type" => "default",
          "cargo_class" => nil,
          "zone" => nil,
          "service" => nil,
          "carrier" => nil,
          "base" => nil,
          "currency" => "EUR"
        }])
      }
    end
    let(:expected_data) do
      { "cargo_class" => "lcl",
        "carriage" => "pre",
        "cbm_ratio" => 250.0,
        "load_type" => "cargo_item",
        "modifier" => "kg",
        "truck_type" => "default",
        "group_id" => "162587c5-0655-416b-a0be-baf07d04063f",
        "hub_id" => 1873,
        "organization_id" => organization.id,
        "tenant_vehicle_id" => 550,
        "zone" => "1.0",
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
                "min_value" => 0.0 }] },
        "fees" =>
          { "FSC" =>
            {
              "base" => nil,
              "min" => nil,
              "max" => nil,
              "name" => "Fuel Surcharge Fee",
              "rate_basis" => "PER_SHIPMENT",
              "currency" => "EUR",
              "shipment" => 30.0,
              "key" => "FSC",
              "range" => []
            } },
        "target" => "20038",
        "secondary" => "20037 - 20039",
        "load_meterage" =>
          { "stackable_type" => "area",
            "non_stackable_type" => "ldm",
            "hard_limit" => false,
            "stackable_limit" => 8.0,
            "non_stackable_limit" => 5.0 },
        "validity" => "[2020-09-01, 2021-12-31)",
        "location_id" => "2547fc53-458b-4614-9d97-aaeec9737ebd" }
    end

    it "returns the frame with the insertable_data" do
      expect(insertable_data.to_a.first).to eq(expected_data)
    end

    context "when it is postal_city style" do
      let(:zone_overrides) { { "identifier" => "postal_city", "city" => "Hamburg" } }

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a.first).to eq(expected_data.merge("secondary" => "Hamburg"))
      end
    end

    context "when it is city style" do
      let(:zone_overrides) { { "identifier" => "city", "city" => "Hamburg", "province" => "Hamburg" } }

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a.first).to eq(expected_data.merge("target" => "Hamburg", "secondary" => "Hamburg"))
      end
    end
  end
end
