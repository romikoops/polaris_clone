# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Coordinates::Range do
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates) }
  let(:section) { "metadata_headers" }
  let(:axis) { "cols" }
  let(:columns) { described_class.new(source: source, section: section, axis: axis).perform }

  describe ".valid?" do
    it "returns successfully" do
      expect(columns).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
    end
  end
end
