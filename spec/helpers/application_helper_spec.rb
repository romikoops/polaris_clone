# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper do
  describe ".format_to_price" do
    it "with hash" do
      expect(helper.format_to_price("value" => 1.231234, "currency" => "EUR")).to eq "1.23 EUR"
    end

    it "with args" do
      expect(helper.format_to_price(1.231234, "EUR")).to eq "1.23 EUR"
    end

    it "with number" do
      expect(helper.format_to_price(1.231234)).to eq "1.23"
    end
  end

  describe ".valid_price_hash?" do
    it "with correct args" do
      expect(helper).to be_valid_price_hash(["value" => 1.231234, "currency" => "EUR"])
      expect(helper).to be_valid_price_hash(["val" => 1.231234, "currency" => "EUR"])
    end

    it "with invalid args" do
      expect(helper).not_to be_valid_price_hash(["amount" => 1.231234, "symbol" => "EUR"])
    end
  end

  describe ".trunc" do
    it "with short text" do
      expect(helper.trunc("shorttext")).to eq "shorttext"
    end

    it "with long text" do
      expect(
        helper.trunc("Brown fox jumped over the fence" * 20)
      ).to eq "Brown fox jumped over the fenceBrown fox jumpe..."
    end
  end

  describe ".line_wrap" do
    it "with short text" do
      expect(helper.line_wrap("shorttext")).to eq "shorttext\n"
    end

    it "with long text" do
      expect(
        helper.line_wrap("Brown fox jumped over the fence" * 20)
      ).to eq(
        "Brown fox jumped over the fenceBrown fox\n"\
        "jumped over the fenceBrown fox jumped\n"\
        "over the fenceBrown fox jumped over th..."
      )
    end
  end

  describe ".formatted_datetime" do
    it "correctly" do
      Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
        expect(helper.formatted_datetime(Time.current)).to eq "22 Feb 2019 | 11:54 AM"
      end
    end
  end

  describe ".formatted_date" do
    it "correctly" do
      Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
        expect(helper.formatted_date(Time.current)).to eq "22 Feb 2019"
      end
    end
  end
end
