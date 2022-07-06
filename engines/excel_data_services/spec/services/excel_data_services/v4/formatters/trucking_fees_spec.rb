# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::TruckingFees do
  include_context "V4 setup"

  let(:result) { described_class.new(data_frame: data_frame, rate_versions: rate_versions).fees }

  describe "#fees" do
    let(:rate_versions) do
      Rover::DataFrame.new([{
        "cargo_class" => "lcl",
        "carrier" => "Gateway Cargo GmbH",
        "service" => "standard",
        "sheet_name" => "Sheet1",
        "carriage" => "pre",
        "truck_type" => "default",
        "organization_id" => organization.id
      }])
    end
    let(:data_frame) do
      Rover::DataFrame.new([{
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
    end
    let(:expected_data) do
      { "cargo_class" => "lcl",
        "carrier" => "Gateway Cargo GmbH",
        "service" => "standard",
        "carriage" => "pre",
        "truck_type" => "default",
        "zone" => nil,
        "organization_id" => organization.id,
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
            } } }
    end

    it "returns the properly formatted fee for the rate version" do
      expect(result.to_a.first).to eq(expected_data)
    end

    context "when there are no fees" do
      let(:data_frame) do
        Rover::DataFrame.new({
          "rate_basis_id" => [],
          "rate_basis" => [],
          "charge_category_id" => [],
          "fee_code" => [],
          "fee_name" => [],
          "sheet_name" => [],
          "organization_id" => [],
          "row" => [],
          "rate" => [],
          "range_min" => [],
          "range_max" => [],
          "modifier" => [],
          "rate_type" => [],
          "column" => [],
          "min" => [],
          "max" => [],
          "target_frame" => [],
          "carriage" => [],
          "truck_type" => [],
          "cargo_class" => [],
          "zone" => [],
          "service" => [],
          "carrier" => [],
          "base" => [],
          "currency" => []
        })
      end

      let(:expected_data) do
        { "cargo_class" => "lcl",
          "carrier" => "Gateway Cargo GmbH",
          "service" => "standard",
          "carriage" => "pre",
          "zone" => nil,
          "truck_type" => "default",
          "organization_id" => organization.id,
          "fees" => {} }
      end

      it "returns the variant with an empty fees hash" do
        expect(result.to_a.first).to eq(expected_data)
      end
    end
  end
end
