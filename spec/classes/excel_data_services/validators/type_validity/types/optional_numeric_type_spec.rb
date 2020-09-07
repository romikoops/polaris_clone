# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericType do
  describe ".valid?" do
    it "returns true if input is an integer" do
      expect(described_class.new(1).valid?).to be
    end

    it "returns true if input is 0" do
      expect(described_class.new(0).valid?).to be
    end

    it "returns true if input is nil" do
      expect(described_class.new(nil).valid?).to be
    end

    it "returns true if input is a float" do
      expect(described_class.new(1.1).valid?).to be
    end

    it "returns false if input is not a valid number" do
      expect(described_class.new("31").valid?).not_to be
    end
  end
end
