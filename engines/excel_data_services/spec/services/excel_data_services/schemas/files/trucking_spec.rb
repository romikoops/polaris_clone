# frozen_string_literal: true

require "rails_helper"
require "./lib/roo/excelx_money"

RSpec.describe ExcelDataServices::Schemas::Files::Trucking do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:xlsx) { Roo::ExcelxMoney.new(file_fixture("excel/example_trucking.xlsx").to_s) }

  describe ".valid?" do
    it "returns successfully" do
      expect(described_class.new(file: xlsx).valid?).to eq(true)
    end

    context "when the file is not valid" do
      let(:xlsx) { Roo::ExcelxMoney.new(file_fixture("dummy.xlsx").to_s) }

      it "returns unsuccessfully" do
        expect(described_class.new(file: xlsx).valid?).to eq(false)
      end
    end
  end
end
