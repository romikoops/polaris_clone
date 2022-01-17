# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Sanitizers::Date do
  let(:value) { nil }
  let(:sanitized_result) { described_class.sanitize(value: value) }

  describe "#sanitize" do
    context "when value is nil" do
      it "returns nil" do
        expect(sanitized_result).to be_nil
      end
    end

    context "when value is a string" do
      let(:value) { "30 Dec 2021" }

      it "returns a date" do
        expect(sanitized_result).to be_a(Date)
      end
    end
  end
end
