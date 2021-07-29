# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Coordinates::Base do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }
  let(:schema) { source.schema }
  let(:coordinates) { schema.dig(section, axis) }
  let(:section) { "column_types" }
  let(:axis) { "cols" }
  let(:klass) { described_class.get(coordinates: coordinates) }

  describe ".get" do
    context "when section is dynamic" do
      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Coordinates::Dynamic)
      end
    end

    context "when section is a list" do
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_zones, file: xlsx, sheet_name: "Zones") }
      let(:section) { "zone_data" }

      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Coordinates::List)
      end
    end

    context "when section is a range" do
      let(:section) { "metadata_headers" }

      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Coordinates::Range)
      end
    end

    context "when section is relative" do
      let(:section) { "metadata_data" }

      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Coordinates::Relative)
      end
    end
  end

  context "instance methods" do
    let(:klass) { described_class.new(source: source, section: section, axis: axis) }

    it "returns the correct child class" do
      expect(klass.limits).to eq([])
    end
  end
end
