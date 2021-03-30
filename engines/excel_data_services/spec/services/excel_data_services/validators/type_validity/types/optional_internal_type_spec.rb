# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalInternalType do
  describe ".valid?" do
    it "returns true if internal is valid" do
      expect(described_class.new("X")).to be_valid
    end

    it "returns false if internal is invalid" do
      expect(described_class.new(123)).not_to be_valid
    end

    it "returns false if internal is of unknown type" do
      expect(described_class.new(true)).not_to be_valid
    end
  end
end
