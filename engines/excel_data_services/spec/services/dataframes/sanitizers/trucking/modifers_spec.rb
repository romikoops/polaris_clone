# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Modifiers do
  let(:sanitizer) { described_class.new(value: value, attribute: attribute) }
  let(:sanitized_value) { sanitizer.perform }

  describe ".sanitize" do
    context "when the value is a string" do
      let(:value) { "KG " }
      let(:attribute) { "modifier" }
      let(:expected_result) { "kg" }

      it "returns the sanitized data", :aggregate_failures do
        expect(sanitized_value).to eq(expected_result)
      end
    end
  end
end
