# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalBooleanType do
  describe ".valid?" do
    it "returns true if input is a boolean" do
      expect(described_class.new(true).valid?).to be
    end

    it "returns true if input is a boolean" do
      expect(described_class.new(false).valid?).to be
    end

    it "returns true if input is nil" do
      expect(described_class.new(nil).valid?).to be
    end

    it "returns false if input is not a valid boolean" do
      expect(described_class.new("true").valid?).not_to be
    end
  end
end
