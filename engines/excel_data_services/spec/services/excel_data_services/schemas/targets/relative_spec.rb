# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Targets::Relative do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }
  let(:section) { "metadata_data" }
  let(:axis) { "cols" }
  let(:columns) { described_class.new(source: source, section: section, axis: axis).perform }

  describe ".valid?" do
    let(:expected_result) do
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17].map { |num| [num] }
    end

    it "returns successfully" do
      expect(columns).to eq(expected_result)
    end
  end
end
