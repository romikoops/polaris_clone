# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Sanitizers::Upcase do
  let(:value) { nil }
  let(:sanitized_result) { described_class.sanitize(value: value) }

  describe "#sanitize" do
    context "when value is nil" do
      it "returns nil if the value is nil" do
        expect(sanitized_result).to be_nil
      end
    end

    context "when value is capitatlized with trailing whitespace" do
      let(:value) { "abc  " }

      it "returns without trailing whitespace" do
        expect(sanitized_result).to eq("ABC")
      end
    end
  end
end
