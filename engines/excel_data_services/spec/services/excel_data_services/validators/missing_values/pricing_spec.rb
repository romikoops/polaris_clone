# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::MissingValues::Pricing do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:validator) { described_class.new(organization: organization, sheet_name: "Sheet1", data: data) }
  let(:data) do
    [[{ sheet_name: "Sheet1",
        restructurer_name: "pricing_one_fee_col_and_ranges",
        rate_basis: "PER_WM_RANGE",
        fee_code: "BAS",
        fee_name: "Bas",
        currency: "USD",
        fee_min: 17,
        fee: 17,
        range: range,
        row_nr: 2 }]]
  end
  let(:range) { nil }
  let(:expected_errors) do
    [{ exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRange,
       reason: "When the rate basis includes \"_RANGE\", there must be a value provided in the RANGE_MIN and RANGE_MAX column",
       row_nr: 2,
       sheet_name: "Sheet1",
       type: :error }]
  end

  before { FactoryBot.create(:pricings_rate_basis, internal_code: "PER_SINGLE_TON") }

  describe ".perform" do
    before { validator.perform }

    it "detects unknown rate basis and missing values rate basis", :aggregate_failures do
      expect(validator.valid?).to be(false)
      expect(validator.results).to match_array(expected_errors)
    end

    context "when one value in range is nil" do
      let(:range) { [nil, { range_min: 1, range_max: 2 }] }

      it "detects unknown rate basis and missing values rate basis", :aggregate_failures do
        expect(validator.valid?).to be(false)
        expect(validator.results).to match_array(expected_errors)
      end
    end

    context "when range is empty" do
      let(:range) { [] }

      it "detects unknown rate basis and missing values rate basis", :aggregate_failures do
        expect(validator.valid?).to be(false)
        expect(validator.results).to match_array(expected_errors)
      end
    end
  end
end
