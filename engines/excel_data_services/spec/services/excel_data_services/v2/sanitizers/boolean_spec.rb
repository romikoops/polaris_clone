# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Sanitizers::Boolean do
  let(:value) { nil }
  let(:sanitized_result) { described_class.sanitize(value: value) }

  describe ".sanitize" do
    context "when value is nil" do
      it "returns a boolean value" do
        expect(sanitized_result).to eq(false)
      end
    end

    context "when value is a float" do
      let(:value) { 1.0 }

      it "returns a boolean value" do
        expect(sanitized_result).to eq(true)
      end
    end

    context "when value is a string" do
      let(:value) { "t" }

      it "returns a boolean value" do
        expect(sanitized_result).to eq(true)
      end
    end

    context "when value is a TrueClass" do
      let(:value) { true }

      it "returns a boolean value" do
        expect(sanitized_result).to eq(true)
      end
    end

    context "when value is a FalseClass" do
      let(:value) { false }

      it "returns a boolean value" do
        expect(sanitized_result).to eq(false)
      end
    end
  end
end
