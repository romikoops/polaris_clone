# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Values do
  let(:sanitizer) { described_class.new(value: value, attribute: attribute) }
  let(:sanitized_value) { sanitizer.perform }

  describe ".sanitize" do
    context "when the value is a string" do
      let(:value) { "100.0 " }
      let(:attribute) { "value" }
      let(:expected_result) { 100.0 }

      it "returns the sanitized data", :aggregate_failures do
        expect(sanitized_value).to eq(expected_result)
      end
    end
  end
end
