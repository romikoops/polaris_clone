# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Ranges::RateRow do
  let(:row) do
    {
      "rate" => {
        "rate" => 100.0,
        "rate_basis" => "PER_WM",
        "currency" => "EUR"
      },
      "min_value" => 1.0,
      "max_value" => 1000.0,
      "min_kg" => 400.0,
      "max_kg" => 500.0
    }
  end
  let(:rate_row) { described_class.new(row: row) }

  describe "#rate_basis" do
    it "returns the rate_basis value out of the row" do
      expect(rate_row.rate_basis).to eq(row.dig("rate", "rate_basis"))
    end
  end

  describe "#value" do
    it "returns the value value out of the row" do
      expect(rate_row.value).to eq(row.dig("rate", "rate"))
    end
  end

  describe "#currency" do
    it "returns the currency value out of the row" do
      expect(rate_row.currency).to eq(row.dig("rate", "currency"))
    end
  end

  describe "#range_min" do
    it "returns the range_min value out of the row" do
      expect(rate_row.range_min).to eq(row["min_kg"])
    end
  end

  describe "#range_max" do
    it "returns the range_max value out of the row" do
      expect(rate_row.range_max).to eq(row["max_kg"])
    end
  end

  describe "#min_value" do
    it "returns the min_value value out of the row" do
      expect(rate_row.min_value).to eq(row["min_value"])
    end
  end

  describe "#max_value" do
    it "returns the max_value value out of the row" do
      expect(rate_row.max_value).to eq(row["max_value"])
    end
  end

  describe "#monetized_value" do
    it "returns the monetized_value value out of the row" do
      expect(rate_row.monetized_value).to eq(Money.new(row["rate"]["rate"] * 100, row["currency"]))
    end
  end

  describe "#monetized_min_value" do
    it "returns the monetized_min_value value out of the row" do
      expect(rate_row.monetized_min_value).to eq(Money.new(row["min_value"] * 100, row["currency"]))
    end
  end

  describe "#monetized_max_value" do
    it "returns the monetized_max_value value out of the row" do
      expect(rate_row.monetized_max_value).to eq(Money.new(row["max_value"] * 100, row["currency"]))
    end
  end
end
