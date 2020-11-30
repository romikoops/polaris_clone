# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::ZoneType do
  describe ".valid?" do
    it "returns true if is a number" do
      expect(described_class.new(12)).to be_valid
    end

    it "returns true if is a float" do
      expect(described_class.new(12.0)).to be_valid
    end

    it "returns true if is a string is a number" do
      expect(described_class.new("12")).to be_valid
    end

    it "returns false if string has a dash" do
      expect(described_class.new("12-200")).not_to be_valid
    end

    it "returns false if nil" do
      expect(described_class.new(nil)).not_to be_valid
    end
  end
end
