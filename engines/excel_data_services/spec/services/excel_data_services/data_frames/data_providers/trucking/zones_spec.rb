# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DataProviders::Trucking::Zones do
  include_context "with standard trucking setup"

  include_context "with real trucking_sheet"
  let(:trucking_file) { ExcelDataServices::Schemas::Files::Trucking.new(file: xlsx) }
  let(:target_schema) { trucking_file.zone_schema }
  let(:result) { described_class.state(state: combinator_arguments) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".extract" do
    context "when it is a numerical range" do
      let(:expected_result) do
        {
          "primary" => nil,
          "secondary" => "01060 - 01068",
          "country_code" => "DE",
          "zone" => "1.0",
          "zone_row" => 2,
          "sheet_name" => "Zones",
          "identifier" => "zipcode",
          "query_method" => "zipcode",
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.frame.count).to eq(2)
        expect(result.frame.to_a.first).to eq(expected_result)
      end
    end
  end
end
