# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DataProviders::Trucking::Brackets do
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
        { "bracket_row" => 4,
          "bracket_col" => 3,
          "bracket" => "0.0 - 100.0",
          "organization_id" => organization.id,
          "sheet_name" => "Sheet3" }
      end

      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.frame.count).to eq(23)
        expect(result.frame.to_a.first).to eq(expected_result)
      end
    end
  end
end
