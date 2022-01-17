# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Operations::Dynamic::MonthDateValues do
  include_context "V3 setup"

  let(:result) { described_class.new(month: month, row: row).perform }

  context "when the column category is :month" do
    let(:row) do
      {
        "row" => 1,
        "sheet_name" => "Sheet1",
        "effective_date" => Date.parse("01 Sep 2021"),
        "expiration_date" => Date.parse("31 Oct 2021"),
        "Dynamic:curr_month/baf" => month
      }
    end
    let(:month) { "OCT" }

    describe "#perform" do
      it "returns effective_date and expriation_date values for the month in the cell" do
        expect(result).to eq({ "effective_date" => Date.parse("01 Oct 2021"), "expiration_date" => Date.parse("31 Oct 2021") })
      end

      context "when the month is out of range of the effective dates" do
        let(:month) { "DEC" }

        it "returns effective_date and expriation_date values as nil" do
          expect(result).to eq({ "effective_date" => nil, "expiration_date" => nil })
        end
      end

      context "when the month isa german abbreviation" do
        let(:month) { "OKT" }

        it "returns effective_date and expriation_date values for the month in the cell" do
          expect(result).to eq({ "effective_date" => Date.parse("01 Oct 2021"), "expiration_date" => Date.parse("31 Oct 2021") })
        end
      end
    end
  end
end
