# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::PrimaryFeeCode do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    let(:row) do
      {
        "fee_code" => ExcelDataServices::V4::Operations::Dynamic::DataColumn::PRIMARY_CODE_PLACEHOLDER,
        "fee_name" => nil,
        "row" => 2,
        "organization_id" => organization.id
      }
    end

    it "returns the frame with the default fee_code and fee_name", :aggregate_failures do
      expect(extracted_table["fee_code"].to_a).to eq(["bas"])
      expect(extracted_table["fee_name"].to_a).to eq(["BAS"])
    end
  end
end
