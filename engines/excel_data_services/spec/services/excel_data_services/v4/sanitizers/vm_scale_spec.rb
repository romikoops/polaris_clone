# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Sanitizers::VmScale do
  let(:value) { nil }
  let(:sanitized_result) { described_class.sanitize(value: value) }

  describe "#sanitize" do
    context "when value is nil" do
      it "returns nil if the value is nil" do
        expect(sanitized_result).to be_nil
      end
    end

    context "when value is a float greater than 1" do
      let(:value) { 1.5 }

      it "interprets the value as a thousandths and returns that decimal value" do
        expect(sanitized_result).to eq(BigDecimal("0.0015", 4))
      end
    end

    context "when value is a float less than 1" do
      let(:value) { 0.15 }

      it "returns the value as decimal" do
        expect(sanitized_result).to eq(BigDecimal("0.15", 2))
      end
    end

    context "when value is a integer" do
      let(:value) { 2 }

      it "interprets the value as a thousandths and returns that decimal value" do
        expect(sanitized_result).to eq(BigDecimal("0.002", 3))
      end
    end

    context "when value is a string" do
      let(:value) { "0.15" }

      it "converts to decimal then interprets the value as a thousandths and returns that decimal value" do
        expect(sanitized_result).to eq(BigDecimal("0.15", 2))
      end
    end
  end
end
