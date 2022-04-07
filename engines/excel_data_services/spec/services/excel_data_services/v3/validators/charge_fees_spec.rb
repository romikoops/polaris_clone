# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Validators::ChargeFees do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when the rate basis matches the pattern _X_ and base is missing" do
      let(:row) do
        {
          "rate_basis" => "PER_X_KG",
          "kg" => 8,
          "base" => nil,
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) do
        [
          "When the rate basis includes \"_X_\", there must be a value provided in the BASE column"
        ]
      end

      it "returns the state with the missing base error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the rate basis is PER_CBM_TON and cbm / ton values are missing" do
      let(:row) do
        {
          "rate_basis" => "PER_CBM_TON",
          "cbm" => nil,
          "ton" => nil,
          "row" => 2,
          "range_min" => 1,
          "range_max" => 10,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) { ["PER_CBM_TON requires values in all the following columns: cbm, ton."] }

      it "returns the state with the missing cbm and ton error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the rate basis is PER_UNIT_TON_CBM_RANGE and cbm / ton values are missing" do
      let(:row) do
        {
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE",
          "cbm" => nil,
          "ton" => nil,
          "row" => 2,
          "range_min" => 1,
          "range_max" => 10,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) { ["PER_UNIT_TON_CBM_RANGE requires values in either of the following columns: cbm, ton."] }

      it "returns the state with the missing cbm and ton error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the rate basis is PER_UNIT_TON_CBM_RANGE and only one value is present" do
      let(:row) do
        {
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE",
          "cbm" => 2.0,
          "ton" => nil,
          "row" => 2,
          "range_min" => 1,
          "range_max" => 10,
          "sheet_name" => "Sheet1"
        }
      end

      it "returns the state without any errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when the rate basis is PER_KG_RANGE and RANGE_MIN is missing" do
      let(:row) do
        {
          "rate_basis" => "PER_KG_RANGE",
          "kg" => 5,
          "row" => 2,
          "range_min" => nil,
          "range_max" => 10,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) { ["Range configured rows require the values in RANGE_MIN to be present"] }

      it "returns the state with the missing RANGE_MIN error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the rate basis is PER_KG_RANGE and RANGE_MIN is higher than RANGE_MAX" do
      let(:row) do
        {
          "rate_basis" => "PER_KG_RANGE",
          "kg" => 5,
          "row" => 2,
          "range_min" => 20,
          "range_max" => 10,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) { ["Range configured rows require the values in RANGE_MIN are lower than those in RANGE_MAX"] }

      it "returns the state with the sequential RANGE error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the rate basis is a simple one and the corresponding value is missing" do
      let(:row) do
        {
          "rate_basis" => "PER_KG",
          "kg" => nil,
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      let(:error_messages) do
        ["PER_KG requires values in all the following columns: kg."]
      end

      it "returns the state with the missing base error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the value is stored under rate" do
      let(:row) do
        {
          "rate_basis" => "PER_KG",
          "rate" => 16,
          "row" => 2,
          "sheet_name" => "Sheet1"
        }
      end

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end
  end
end
