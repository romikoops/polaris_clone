# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::PricingOneFeeColAndRanges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, data: input_data} }

  describe ".restructure" do
    let(:input_data) { FactoryBot.build(:excel_data_parsed_correct_pricings_one_fee_col_and_ranges).first }
    let(:output_data) { {"Pricing" => FactoryBot.build(:excel_data_restructured_correct_pricings_one_fee_col_and_ranges)} }
    let(:result) { described_class.restructure(options) }

    it "restructures the data correctly" do
      expect(result["Pricing"]).to match_array(output_data["Pricing"])
    end

    context "when rate_basis is lower_case" do
      let(:input_data) { FactoryBot.build(:excel_data_parsed_to_upcase_pricings_one_fee_col_and_ranges).first }

      it "forces uppercase for rate_basis and restructures correctly" do
        expect(result["Pricing"].first).to match_array(output_data["Pricing"].first)
      end
    end
  end

  describe ".restructure with remarks" do
    let(:input_data) { FactoryBot.build(:excel_data_parsed_correct_pricings_one_fee_col_and_ranges_with_remarks).first }
    let(:output_data) do
      {"Pricing" =>
     FactoryBot.build(:excel_data_restructured_correct_pricings_one_fee_col_and_ranges_with_remarks)}
    end
    let(:result) { described_class.restructure(options) }

    it "restructures the data correctly" do
      expect(result["Pricing"]).to match_array(output_data["Pricing"])
    end
  end
end
