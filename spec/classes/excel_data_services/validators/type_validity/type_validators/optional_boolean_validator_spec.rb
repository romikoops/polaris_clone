# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::OptionalBooleanValidator do
  describe ".valid?" do
    it "returns true if input is a boolean" do
      expect(described_class.new(true)).to be_valid
    end

    it "returns true if input is a boolean" do
      expect(described_class.new(false)).to be_valid
    end

    it "returns true if input is nil" do
      expect(described_class.new(nil)).to be_valid
    end

    it "returns false if input is not a valid boolean" do
      expect(described_class.new("true")).not_to be_valid
    end
  end
end
