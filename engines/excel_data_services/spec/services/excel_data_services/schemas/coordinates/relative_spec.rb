# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Coordinates::Relative do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }
  let(:section) { "metadata_data" }
  let(:axis) { "cols" }
  let(:columns) { described_class.new(source: source, section: section, axis: axis).perform }

  describe ".valid?" do
    it "returns successfully" do
      expect(columns).to eq(1.upto(xlsx.row(1).compact.count).to_a)
    end
  end
end
