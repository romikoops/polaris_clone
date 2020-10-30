# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Validator do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }

  describe ".valid?" do
    it "returns successfully" do
      expect(described_class.valid?(source: source)).to eq(true)
    end
  end
end
