# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneRow do
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
        { "zone_row" => 6,
          "zone_col" => 1,
          "zone" => "1.0",
          "sheet_name" => "Sheet3" }
      end

      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.frame.count).to eq(1)
        expect(result.frame.to_a.first).to eq(expected_result)
      end
    end
  end
end
