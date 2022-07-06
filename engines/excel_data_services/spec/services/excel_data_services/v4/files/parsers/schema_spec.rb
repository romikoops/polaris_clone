# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::Schema do
  let(:service) { described_class.new(section: section, keys: keys) }
  let(:keys) { %i[operations] }
  let(:section) { "pricings" }

  describe "#perform" do
    it "yields the relevant schema data in the block when one is provided" do
      service.perform do |schema_data|
        expect(schema_data).to eq(operations: [{ type: "ExpandedDates" }, { type: "DynamicFees" }])
      end
    end

    it "returns the relevant schema data when no block is provided" do
      expect(service.perform).to eq(operations: [{ type: "ExpandedDates" }, { type: "DynamicFees" }])
    end

    it "raises and InvalidSection error when the path is invalid" do
      expect { described_class.new(section: "blue", keys: keys) }.to raise_error(ExcelDataServices::V4::Files::Parsers::Schema::InvalidSection)
    end
  end
end
