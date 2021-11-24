# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::ModeOfTransportType do
  describe ".valid?" do
    it "returns true if mode of transport is valid" do
      expect(described_class.new("truck")).to be_valid
    end

    it "returns false if locode is a Float" do
      expect(described_class.new(0.0)).not_to be_valid
    end

    it "returns false if locode is a Number" do
      expect(described_class.new(123)).not_to be_valid
    end

    it "returns true if locode is a NilClass" do
      expect(described_class.new(nil)).not_to be_valid
    end
  end
end
