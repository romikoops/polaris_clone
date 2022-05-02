# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::Schema do
  let(:service) { described_class.new(section: section, pattern: pattern, path: path) }
  let(:path) { "section_data" }
  let(:pattern) { /^(add_operation)/ }
  let(:section) { "Pricings" }

  describe "#perform" do
    it "yields the relevant schema lines in the block when one is provided" do
      service.perform do |schema_lines|
        expect(schema_lines).to eq("add_operation \"ExpandedDates\"\nadd_operation \"DynamicFees\"\n")
      end
    end

    it "returns the relevant schema lines when no block is provided" do
      expect(service.perform).to eq("add_operation \"ExpandedDates\"\nadd_operation \"DynamicFees\"\n")
    end

    it "raises and InvalidPath error when the path is invalid" do
      expect { described_class.new(section: section, pattern: pattern, path: "blue") }.to raise_error(ExcelDataServices::V4::Files::Parsers::Schema::InvalidPath)
    end

    it "raises and InvalidSection error when the path is invalid" do
      expect { described_class.new(section: "blue", pattern: pattern, path: path) }.to raise_error(ExcelDataServices::V4::Files::Parsers::Schema::InvalidSection)
    end

    it "raises and InvalidPattern error when the path is invalid" do
      expect { described_class.new(section: section, pattern: "blue", path: path) }.to raise_error(ExcelDataServices::V4::Files::Parsers::Schema::InvalidPattern)
    end
  end

  describe "#dependencies" do
    it "returns the dependencies defined as 'prerequisites'" do
      expect(service.dependencies).to eq(%w[TenantVehicle Itinerary ChargeCategory TransitTime])
    end
  end
end
