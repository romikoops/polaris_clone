# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DataProviders::Trucking::CountryCodes do
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
          "country_code" => "DE",
          "query_method" => "zipcode",
          "identifier" => "zipcode"
        }
      end

      it "returns the frame with the fee data", :aggregate_failures do
        expect(result.frame.count).to eq(2)
        expect(result.frame.to_a.first.inspect).to eq(expected_result.inspect)
      end
    end
  end
end
