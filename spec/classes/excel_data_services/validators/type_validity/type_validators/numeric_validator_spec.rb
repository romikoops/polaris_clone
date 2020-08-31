# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::NumericValidator do
  describe ".valid?" do
    it "returns true if input is a number" do
      expect(described_class.new(10)).to be_valid
    end

    it "returns true if input is a number" do
      expect(described_class.new(0.5)).to be_valid
    end

    it "returns false if input is not a valid number" do
      expect(described_class.new("number")).not_to be_valid
    end
  end
end
