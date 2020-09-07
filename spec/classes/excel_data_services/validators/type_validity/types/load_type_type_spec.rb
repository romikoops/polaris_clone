# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::LoadTypeType do
  describe ".valid?" do
    it "returns true if load type is valid" do
      expect(described_class.new("container").valid?).to be
    end

    it "returns true if load type is valid, but capitalized" do
      expect(described_class.new("cargo_item").valid?).to be
    end

    it "returns false if load type is invalid" do
      expect(described_class.new("some other string").valid?).not_to be
    end

    it "returns false if load type is not a String" do
      expect(described_class.new(123).valid?).not_to be
    end
  end
end
