# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalLocodeType do
  describe ".valid?" do
    it "returns true if optional locode is valid" do
      expect(described_class.new("DE HAM")).to be_valid
    end

    it "returns false if optional locode is invalid" do
      expect(described_class.new("12ABC")).not_to be_valid
    end

    it "returns true if optional locode is nil" do
      expect(described_class.new(nil)).to be_valid
    end
  end
end
