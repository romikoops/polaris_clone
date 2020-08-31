# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::IntegerValidator do
  describe ".valid?" do
    it "returns true if input is an integer" do
      expect(described_class.new(10)).to be_valid
    end

    it "returns false if input is a float" do
      expect(described_class.new(10.8)).not_to be_valid
    end
  end
end
