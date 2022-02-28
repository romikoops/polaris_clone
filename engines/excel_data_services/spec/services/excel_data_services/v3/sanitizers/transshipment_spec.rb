# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Sanitizers::Transshipment do
  let(:value) { nil }
  let(:sanitized_result) { described_class.sanitize(value: value) }

  describe "#sanitize" do
    context "when value is nil" do
      it "returns nil if the value is nil" do
        expect(sanitized_result).to be_nil
      end
    end

    context "when value is `direct` in different cases" do
      %w[direct DIRECT direkt DIREKT DirEcT].each do |value|
        let(:value) { value }

        it "returns nil" do
          expect(sanitized_result).to be_nil
        end
      end
    end

    context "when value is a valid transshipment" do
      let(:value) { "CNSGH" }

      it "returns valid transshipment" do
        expect(sanitized_result).to eq("CNSGH")
      end
    end
  end
end
