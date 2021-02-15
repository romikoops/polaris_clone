# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Fees do
  let(:frame_data) do
    {"fee" => "Fuel Surcharge Fee ",
     "mot" => "Ocean",
     "fee_code" => "fsc",
     "truck_type" => "Default",
     "direction" => "Export",
     "currency" => "eur",
     "rate_basis" => "per_shipment",
     "ton" => 20,
     "cbm" => nil,
     "kg" => nil,
     "item" => nil,
     "shipment" => "30.0",
     "bill" => nil,
     "container" => nil,
     "minimum" => nil,
     "wm" => nil,
     "percentage" => nil}
  end
  let(:expected_results) do
    {"fee" => "Fuel Surcharge Fee",
     "mot" => "ocean",
     "fee_code" => "FSC",
     "truck_type" => "default",
     "direction" => "export",
     "currency" => "EUR",
     "rate_basis" => "PER_SHIPMENT",
     "ton" => 20.0,
     "cbm" => nil,
     "kg" => nil,
     "item" => nil,
     "shipment" => 30.0,
     "bill" => nil,
     "container" => nil,
     "minimum" => nil,
     "wm" => nil,
     "percentage" => nil}
  end

  describe ".sanitize" do
    it "sanitizes each value correctly", :aggregate_failures do
      frame_data.each do |attribute, value|
        sanitized_value = described_class.sanitize(value: value, attribute: attribute)
        expect(sanitized_value).to eq(expected_results[attribute])
      end
    end
  end
end
