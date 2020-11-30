# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Sheet::TruckingRates do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  include_context "with real trucking_sheet"

  describe ".valid?" do
    it "returns successfully" do
      expect(described_class.new(file: xlsx, sheet_name: "Sheet3").valid?).to eq(true)
    end
  end
end
