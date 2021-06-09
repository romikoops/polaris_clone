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
        { "fee" => "Fuel Surcharge Fee",
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
          "range_max" => nil,
          "range_min" => nil,
          "organization_id" => organization.id,
          "sheet_name" => "Fees" }
      end

      it "returns the frame with the fee data" do
        expect(result.frame.to_a).to eq([expected_result])
      end
    end
  end
end
