# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Sanitizers::Distance do
  let(:value) { nil }
  let(:sanitized_result) { described_class.sanitize(value: value) }

  describe "#sanitize" do
    context "when value is nil" do
      it "returns nil if the value is nil" do
        expect(sanitized_result).to be_nil
      end
    end

    context "when value is a float" do
      let(:value) { 1.2 }

      it "returns the float converted to integer, then as a string" do
        expect(sanitized_result).to eq("1")
      end
    end

    context "when value is an integer" do
      let(:value) { 1 }

      it "returnsthe integer as a string" do
        expect(sanitized_result).to eq("1")
      end
    end
  end
end
