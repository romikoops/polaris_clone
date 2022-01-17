# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Helpers::Prefixer do
  describe "#prefix_key" do
    let(:result) { described_class.new(prefix: prefix).prefix_key(key: "hub") }

    context "when the prefix is 'origin'" do
      let(:prefix) { "origin" }

      it "returns the key with the prefix prepended" do
        expect(result).to eq("origin_hub")
      end
    end

    context "when the prefix is blank" do
      let(:prefix) { "" }

      it "returns the key untouched" do
        expect(result).to eq("hub")
      end
    end
  end
end
