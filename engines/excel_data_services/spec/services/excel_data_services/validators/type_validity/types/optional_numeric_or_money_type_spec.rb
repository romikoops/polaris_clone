# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::OptionalNumericOrMoneyType do
  describe ".valid?" do
    it "returns true if input is a NilClass" do
      expect(described_class.new(nil)).to be_valid
    end

    it "returns true if input is an Integer" do
      expect(described_class.new(1)).to be_valid
    end

    it "returns true if input is 0" do
      expect(described_class.new(0)).to be_valid
    end

    it "returns true if input is a Float" do
      expect(described_class.new(1.1)).to be_valid
    end

    it "returns true if input is a Money" do
      expect(described_class.new(Money.new(1))).to be_valid
    end

    it "returns false if input is not a valid number" do
      expect(described_class.new("0.foo")).not_to be_valid
    end
  end
end
