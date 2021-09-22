# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DataProviders::Trucking::Fees do
  include_context "with standard trucking setup"

  include_context "with real trucking_sheet"
  let(:trucking_file) { ExcelDataServices::Schemas::Files::Trucking.new(file: xlsx) }
  let(:target_schema) { trucking_file.fee_schema }
  let(:result) { described_class.state(state: combinator_arguments) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".extract" do
    context "when it is a numerical range" do
      let(:expected_result) do
        [{ "service" => nil,
           "carrier" => nil,
           "cargo_class" => nil,
           "zone" => nil,
           "fee" => "Fuel Surcharge Fee",
           "mot" => "ocean",
           "fee_code" => "FSC",
           "truck_type" => "default",
           "direction" => "export",
           "currency" => "EUR",
           "rate_basis" => "PER_SHIPMENT",
           "ton" => nil,
           "cbm" => nil,
           "kg" => nil,
           "item" => nil,
           "shipment" => 30.0,
           "bill" => nil,
           "container" => nil,
           "minimum" => nil,
           "wm" => nil,
           "percentage" => nil,
           "range_min" => nil,
           "range_max" => nil,
           "sheet_name" => "Fees",
           "organization_id" => organization.id },
          { "service" => nil,
            "carrier" => nil,
            "cargo_class" => nil,
            "zone" => "1.0",
            "fee" => "Pickup Fee",
            "mot" => "ocean",
            "fee_code" => "PUF",
            "truck_type" => "default",
            "direction" => "export",
            "currency" => "USD",
            "rate_basis" => "PER_KG",
            "ton" => nil,
            "cbm" => nil,
            "kg" => 15,
            "item" => nil,
            "shipment" => nil,
            "bill" => nil,
            "container" => nil,
            "minimum" => nil,
            "wm" => nil,
            "percentage" => nil,
            "range_min" => nil,
            "range_max" => nil,
            "sheet_name" => "Fees",
            "organization_id" => organization.id },
          { "service" => "Faster",
            "carrier" => "Gateway Cargo GmbH",
            "cargo_class" => nil,
            "zone" => nil,
            "fee" => "Terminal Handling Cost",
            "mot" => "ocean",
            "fee_code" => "THC",
            "truck_type" => "default",
            "direction" => "export",
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
            "sheet_name" => "Fees",
            "organization_id" => organization.id }]
      end

      it "returns the frame with the fee data" do
        expect(result.frame.to_a).to eq(expected_result)
      end
    end
  end
end
