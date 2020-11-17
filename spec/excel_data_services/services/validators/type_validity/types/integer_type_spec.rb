# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::IntegerType do
  describe ".valid?" do
    it "returns true if input is an integer" do
      expect(described_class.new(10).valid?).to be
    end

    it "returns false if input is a float" do
      expect(described_class.new(10.8).valid?).not_to be
    end
  end
end
