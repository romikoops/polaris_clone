# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata do
  include_context "with standard trucking setup"

  include_context "with real trucking_sheet"
  let(:trucking_file) { ExcelDataServices::Schemas::Files::Trucking.new(file: xlsx) }
  let(:target_schema) { trucking_file.rate_schemas.first }
  let(:result) { described_class.state(state: combinator_arguments) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".extract" do
    context "when it is a numerical range" do
      let(:expected_result) do
        {"city" => "Hamburg",
         "currency" => "EUR",
         "load_meterage_ratio" => nil,
         "load_meterage_limit" => nil,
         "load_meterage_area" => nil,
         "cbm_ratio" => 250.0,
         "scale" => "kg",
         "rate_basis" => "PER_SHIPMENT",
         "base" => 1.0,
         "truck_type" => "default",
         "load_type" => "cargo_item",
         "cargo_class" => "lcl",
         "direction" => "export",
         "carrier" => "Gateway Cargo GmbH",
         "service" => nil,
         "effective_date" => Date.parse("Tue, 01 Sep 2020"),
         "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
         "sheet_name" => "Sheet3"}
      end

      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.frame.count).to eq(1)
        expect(result.frame.to_a.first.inspect).to eq(expected_result.inspect)
      end
    end
  end
end
