# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalMonthType do
  describe "#valid?" do
    it "returns false if input is an integer" do
      expect(described_class.new(1)).not_to be_valid
    end

    it "returns false if input is a 0" do
      expect(described_class.new(0)).not_to be_valid
    end

    it "returns false if input is a Float that has no decimal part" do
      expect(described_class.new(5.0)).not_to be_valid
    end

    it "returns true if input is nil" do
      expect(described_class.new(nil)).to be_valid
    end

    it "returns true if input is a valid month" do
      expect(described_class.new("january")).to be_valid
    end

    it "returns true if input is a valid 3 letter month abreviation" do
      expect(described_class.new("JAN")).to be_valid
    end

    it "returns true if input is a valid 3 letter German month abreviation" do
      expect(described_class.new("DEZ")).to be_valid
    end

    it "returns false if input is not a vlaid month abbreviation" do
      expect(described_class.new("apple")).not_to be_valid
    end

    it "returns false if input is a an unexpected type" do
      expect(described_class.new(true)).not_to be_valid
    end
  end
end
