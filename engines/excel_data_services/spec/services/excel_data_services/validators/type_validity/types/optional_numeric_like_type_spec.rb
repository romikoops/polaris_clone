# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericLikeType do
  describe ".valid?" do
    it "returns true if input is an integer" do
      expect(described_class.new(1).valid?).to be
    end

    it "returns true if input is a 0" do
      expect(described_class.new(0).valid?).to be
    end

    it "returns true if input is a Float that has no decimal part" do
      expect(described_class.new(5.0).valid?).to be
    end

    it "returns true if input is nil" do
      expect(described_class.new(nil).valid?).to be
    end

    it "returns true if input is a valid integer ins tring form" do
      expect(described_class.new("31.0").valid?).to be
    end

    it "returns false if input is a Float that has a decimal part" do
      expect(described_class.new(5.2).valid?).to be
    end

    it "returns false if input is a an unexpected type" do
      expect(described_class.new(true).valid?).not_to be
    end
  end
end
