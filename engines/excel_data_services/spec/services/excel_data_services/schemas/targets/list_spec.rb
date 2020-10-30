# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Targets::List do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_zones, file: xlsx, sheet_name: "Zones") }
  let(:section) { "zone_data" }
  let(:axis) { "cols" }
  let(:columns) { described_class.new(source: source, section: section, axis: axis).perform }

  describe ".valid?" do
    it "returns successfully" do
      expect(columns).to eq([["B", "C"], ["D"]])
    end
  end
end
