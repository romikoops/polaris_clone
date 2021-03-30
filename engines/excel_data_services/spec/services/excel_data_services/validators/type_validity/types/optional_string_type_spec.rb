# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalStringType do
  describe ".valid?" do
    it "returns true if optional string is valid" do
      expect(described_class.new("abc de")).to be_valid
    end

    it "returns false if optional string is invalid" do
      expect(described_class.new(123)).not_to be_valid
    end
  end
end
