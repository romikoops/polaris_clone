# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::Dynamic::DataColumn do
  include_context "V4 setup"

  let(:data_column) { described_class.new(header: header, frame: frame) }

  context "when the column category is :month" do
    let(:rows) do
      [{
        "row" => 1,
        "sheet_name" => "Sheet1",
        "effective_date" => Date.parse("01 Sep 2021"),
        "expiration_date" => Date.parse("31 Dec 2021"),
        header => "NOV"
      }]
    end
    let(:header) { "Dynamic(Sheet1-11):curr_month/baf" }

    describe "#data" do
      it "returns the turns each row into a row for each fee defined in the dynamic columns", :aggregate_failures do
        expect(data_column.data.to_a).to eq(
          [{ "row" => 1, "sheet_name" => "Sheet1", "effective_date" => Date.parse("01 Nov 2021"), "expiration_date" => Date.parse("30 Nov 2021") }]
        )
      end
    end

    describe "#fee_code" do
      it "returns the correct fee_code from the header" do
        expect(data_column.fee_code).to eq("baf")
      end

      context "when the fee_code is to be replaced with the Primary Fee Code in the PrimaryFeeCode Extractor" do
        let(:header) { "Dynamic(Sheet1-11):20dc" }

        it "returns the correct fee_code from the header" do
          expect(data_column.fee_code).to eq(described_class::PRIMARY_CODE_PLACEHOLDER)
        end
      end

      context "when the dynamic key includes underscores" do
        let(:header) { "Dynamic(Sheet_1-11):curr_month/baf" }

        it "returns the correct fee_code from the header" do
          expect(data_column.fee_code).to eq("baf")
        end
      end
    end

    describe "#category" do
      it "returns the correct category from the header" do
        expect(data_column.category).to eq(:month)
      end
    end

    describe "#current?" do
      it "returns true when header include CURR" do
        expect(data_column.current?).to eq(true)
      end

      context "when header is NEXT_MONTH" do
        let(:header) { "Dynamic(Sheet1-11):next_month/baf" }

        it "returns true when header include NEXT" do
          expect(data_column.current?).to eq(false)
        end
      end
    end
  end

  context "when the column category is :fee" do
    let(:row) do
      {
        "row" => 1,
        "cargo_class" => nil,
        "sheet_name" => "Sheet1",
        "effective_date" => Date.parse("01 Sep 2021"),
        "expiration_date" => Date.parse("31 Dec 2021"),
        header => value
      }
    end
    let(:value) { Money.new(1500, "EUR") }
    let(:header) { "Dynamic(Sheet1-11):curr_fee/20/baf" }

    describe "#data" do
      it "returns each cell in column expanded to a full fee", :aggregate_failures do
        expect(data_column.data.to_a).to eq(
          [row.except(header).merge("cargo_class" => "fcl_20", "rate" => 15.0, "currency" => "EUR", "fee_code" => "baf", "fee_name" => "BAF")]
        )
      end

      context "when cell is 'incl'" do
        let(:value) { "incl" }

        it "returns each cell in column expanded to a full fee", :aggregate_failures do
          expect(data_column.data.to_a).to eq(
            [row.except(header).merge("cargo_class" => "fcl_20", "rate" => 0, "currency" => "USD", "fee_code" => "included_baf", "fee_name" => "BAF")]
          )
        end
      end
    end

    describe "#fee_code" do
      it "returns the correct fee_code from the header" do
        expect(data_column.fee_code).to eq("baf")
      end
    end

    describe "#category" do
      it "returns the correct category from the header" do
        expect(data_column.category).to eq(:fee)
      end
    end

    describe "#current?" do
      it "returns true when header include CURR" do
        expect(data_column.current?).to eq(true)
      end

      context "when header is NEXT_MONTH" do
        let(:header) { "Dynamic(Sheet1-11):next_fee/20/baf" }

        it "returns true when header include CURR" do
          expect(data_column.current?).to eq(false)
        end
      end
    end

    describe "#cargo_classes" do
      context "when header is one of the main 3 dynamic fees" do
        let(:header) { "Dynamic(Sheet1-11):20dc" }

        it "returns 'fcl_20' when header is '20DC'" do
          expect(data_column.cargo_classes.to_a).to match_array([
            row.slice("row", "sheet_name").merge("cargo_class" => "fcl_20")
          ])
        end
      end

      context "when header has cargo class between slashes" do
        let(:header) { "Dynamic:next_fee/40/baf" }

        it "returns both 40 ft cargo classes" do
          expect(data_column.cargo_classes.to_a).to match_array([
            row.slice("row", "sheet_name").merge("cargo_class" => "fcl_40"),
            row.slice("row", "sheet_name").merge("cargo_class" => "fcl_40_hq")
          ])
        end
      end
    end
  end
end
