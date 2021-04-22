# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Targets::Relative do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }
  let(:section) { "metadata_data" }
  let(:axis) { "cols" }
  let(:row_target) { "1" }
  let(:columns) { described_class.new(source: source, section: section, axis: axis).perform }

  describe ".valid?" do
    let(:expected_result) { 1.upto(xlsx.row(1).compact.count).map { |num| [num] } }

    it "returns successfully" do
      expect(columns).to eq(expected_result)
    end
  end
end
