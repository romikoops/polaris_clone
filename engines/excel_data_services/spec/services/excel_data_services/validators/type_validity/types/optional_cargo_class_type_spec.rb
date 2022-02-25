# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalCargoClassType do
  describe ".valid?" do
    it "returns true if cargo class is valid" do
      expect(described_class.new("lcl")).to be_valid
    end

    it "returns false if cargo class is invalid" do
      expect(described_class.new("blue")).not_to be_valid
    end

    it "returns true if cargo class is nil" do
      expect(described_class.new(nil)).to be_valid
    end

    it "returns false if cargo class is a TrueClass" do
      expect(described_class.new(true)).not_to be_valid
    end
  end
end
