# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::StringType do
  describe ".valid?" do
    it "returns true if string is valid" do
      expect(described_class.new("abc de").valid?).to be
    end

    it "returns false if string is invalid" do
      expect(described_class.new(123).valid?).not_to be
    end
  end
end
