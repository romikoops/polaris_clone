# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::FeeType do
  describe ".valid?" do
    it "returns true if fee is valid" do
      expect(described_class.new("n/a").valid?).to be
    end

    it "returns false if fee is invalid" do
      expect(described_class.new(nil).valid?).not_to be
    end
  end
end
