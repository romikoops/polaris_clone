# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::Trucking do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    let(:rows) { FactoryBot.build(:excel_data_services_section_data, :trucking, organization: organization) }
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
        "rates" =>
          { "kg" =>
            [{ "rate" => { "currency" => "EUR", "rate_basis" => "PER_SHIPMENT", "base" => 1.0 },
               "min_kg" => 0.0,
               "max_kg" => 100.0,
               "min_value" => "0.0" },
              { "rate" => { "currency" => "EUR", "rate_basis" => "PER_SHIPMENT", "base" => 1.0 },
                "min_kg" => 100.0,
                "max_kg" => 200.0,
                "min_value" => "0.0" },
              { "rate" => { "currency" => "EUR", "rate_basis" => "PER_SHIPMENT", "base" => 1.0 },
                "min_kg" => 200.0,
                "max_kg" => 300.0,
                "min_value" => "0.0" }] },
        "fees" =>
          { "FSC" =>
            {
              "base" => nil,
              "min" => nil,
              "max" => nil,
              "name" => "Fuel Surcharge Fee",
              "rate_basis" => "PER_SHIPMENT",
              "currency" => "EUR",
              "rate" => 30.0,
              "key" => "FSC",
              "range" => [] } },
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

    context "when 'load_meterage_stackable_type' is blank" do
      let(:rows) do
        FactoryBot.build(:excel_data_services_section_data, :trucking, organization: organization)
          .tap do |frame|
            frame.delete("load_meterage_stackable_type")
            frame["load_meterage_area"] = 2
            frame
          end
      end

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a.first).to eq(expected_data)
      end
    end
  end
end
