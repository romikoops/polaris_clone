# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::CargoClassValidator do
  describe ".valid?" do
    it "returns true if cargo class is valid" do
      expect(described_class.new("fcl_10")).to be_valid
    end

    it "returns false if cargo class is nil" do
      expect(described_class.new(nil)).not_to be_valid
    end
  end
end
