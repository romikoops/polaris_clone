# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Restructurers::Truckings::Rates do
  include_context "with standard trucking setup"

  let(:sheet_names) { ["Rates"] }
  let(:input_rows) do
    sheet_names.map do |sheet_name|
      {"value" => 1.98,
       "value_row" => 6,
       "value_col" => 5,
       "sheet_name" => sheet_name,
       "modifier" => "kg",
       "modifier_row" => 3,
       "modifier_col" => 5,
       "zone" => "1.0",
       "zone_row" => 6,
       "zone_col" => "A",
       "bracket" => "0-0",
       "bracket_row" => 4,
       "bracket_col" => 5,
       "max" => 0.0,
       "min" => 0.0,
       "zone_minimum" => nil,
       "zone_minimum_row" => nil,
       "zone_minimum_col" => nil,
       "bracket_minimum" => 25.0,
       "bracket_minimum_row" => 5,
       "bracket_minimum_col" => 5,
       "currency" => "EUR",
       "load_meterage_ratio" => nil,
       "load_meterage_limit" => nil,
       "load_meterage_area" => nil,
       "cbm_ratio" => 200.0,
       "scale" => "kg",
       "rate_basis" => "PER_SHIPMENT",
       "base" => 1.0}
    end
  end
  let(:input) do
    Rover::DataFrame.new(input_rows)
  end
  let(:result) { described_class.data(frame: input) }
  let(:restructured_rates) { result.to_a.first["rates"] }

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    context "when it is a single sheet" do
      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.count).to eq(1)
        expect(result.keys).to eq(["rates", "sheet_name", "zone"])
        expect(restructured_rates.keys).to eq(["kg"])
        expect(restructured_rates.dig("kg", 0, :rate)).to eq(
          {"currency" => "EUR", "rate_basis" => "PER_SHIPMENT", "base" => 1.0, "value" => 1.98}
        )
      end
    end

    context "when there are multiple sheets" do
      let(:sheet_names) { ["Import", "Export"]}

      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.count).to eq(2)
        expect(result["sheet_name"].uniq).to match_array(sheet_names)
      end
    end
  end
end
