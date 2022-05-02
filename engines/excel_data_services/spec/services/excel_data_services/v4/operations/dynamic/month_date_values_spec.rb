# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::Dynamic::MonthDateValues do
  include_context "V4 setup"

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
      it "returns effective_date and expiration_date values for the month in the cell" do
        expect(result).to eq({ "effective_date" => Date.parse("01 Oct 2021"), "expiration_date" => Date.parse("31 Oct 2021") })
      end

      context "when the month is out of range of the effective dates" do
        let(:month) { "DEC" }

        it "returns effective_date and expiration_date values as nil" do
          expect(result).to eq({ "effective_date" => nil, "expiration_date" => nil })
        end
      end

      context "when the month isa german abbreviation" do
        let(:month) { "OKT" }

        it "returns effective_date and expiration_date values for the month in the cell" do
          expect(result).to eq({ "effective_date" => Date.parse("01 Oct 2021"), "expiration_date" => Date.parse("31 Oct 2021") })
        end
      end

      context "when the month is halfway done before the rate starts" do
        let(:row) do
          {
            "row" => 1,
            "sheet_name" => "Sheet1",
            "effective_date" => Date.parse("15 Oct 2021"),
            "expiration_date" => Date.parse("31 Oct 2021"),
            "Dynamic:curr_month/baf" => month
          }
        end

        it "returns effective_date and expiration_date values for the month in the cell" do
          expect(result).to eq({ "effective_date" => Date.parse("15 Oct 2021"), "expiration_date" => Date.parse("31 Oct 2021") })
        end
      end

      context "when the rate starts at the end of the month" do
        let(:row) do
          {
            "row" => 1,
            "sheet_name" => "Sheet1",
            "effective_date" => Date.parse("31 Oct 2021"),
            "expiration_date" => Date.parse("30 Nov 2021"),
            "Dynamic:curr_month/baf" => month
          }
        end

        it "returns effective_date and expiration_date values for the month in the cell" do
          expect(result).to eq({ "effective_date" => Date.parse("31 Oct 2021"), "expiration_date" => Date.parse("31 Oct 2021") })
        end
      end

      context "when the month is Feb during a leap year" do
        let(:row) do
          {
            "row" => 1,
            "sheet_name" => "Sheet1",
            "effective_date" => Date.parse("28 Feb 2024"),
            "expiration_date" => Date.parse("31 March 2024"),
            "Dynamic:curr_month/baf" => month
          }
        end

        let(:month) { "FEB" }

        it "returns effective_date and expiration_date values for the month in the cell in a leap year" do
          expect(result).to eq({ "effective_date" => Date.parse("28 Feb 2024"), "expiration_date" => Date.parse("29 Feb 2024") })
        end
      end
    end
  end
end
