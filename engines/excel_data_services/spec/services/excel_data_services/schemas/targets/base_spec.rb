# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Targets::Base do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }
  let(:schema) { source.schema }
  let(:coordinates) { schema.dig(section, axis) }
  let(:section) { "column_types" }
  let(:axis) { "cols" }
  let(:klass) { described_class.get(coordinates: coordinates) }

  describe "self.get" do
    context "when section is dynamic" do
      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Targets::Dynamic)
      end
    end

    context "when section is a list" do
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_zones, file: xlsx, sheet_name: "Zones") }
      let(:section) { "zone_data" }

      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Targets::List)
      end
    end

    context "when section is a range" do
      let(:section) { "metadata_headers" }

      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Targets::Range)
      end
    end

    context "when section is a range" do
      let(:section) { "metadata_data" }

      it "returns the correct child class" do
        expect(klass).to eq(ExcelDataServices::Schemas::Targets::Relative)
      end
    end
  end
end
