# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Rows::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:row) { described_class.new(organization: organization, row_data: { row_nr: 1, sheet_name: "Test" }) }

  describe "#[]" do
    it "finds the corresponding '.' method (row[:nr] --> row.nr)" do
      expect(row[:nr]).to eq(1)
    end
  end

  describe "#sheet_name" do
    it "returns the sheet name" do
      expect(row.sheet_name).to eq("Test")
    end
  end
end
