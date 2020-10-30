# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::RateBasisType do
  describe ".valid?" do
    it "returns false if is a number" do
      expect(described_class.new(12)).not_to be_valid
    end

    it "returns false if is a float" do
      expect(described_class.new(12.0)).not_to be_valid
    end

    it "returns false if isnil" do
      expect(described_class.new(nil)).not_to be_valid
    end

    it "returns false if is a string not in format" do
      expect(described_class.new("12")).not_to be_valid
    end

    it "returns true if string is valid" do
      expect(described_class.new("PER_SHIPMENT")).to be_valid
    end
  end
end
