# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Sheet::TruckingFees do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  include_context "with real trucking_sheet"

  describe ".valid?" do
    it "returns successfully" do
      expect(described_class.new(file: xlsx.sheet("Fees"), sheet_name: "Fees").valid?).to eq(true)
    end

    it "returns unsuccessfully" do
      expect(described_class.new(file: xlsx.sheet("Zones"), sheet_name: "Zones").valid?).to eq(false)
    end
  end
end
