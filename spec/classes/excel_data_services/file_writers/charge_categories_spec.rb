# frozen_string_literal: true

require "rails_helper"
require "roo"

RSpec.describe ExcelDataServices::FileWriters::ChargeCategories do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let!(:charge_category) { FactoryBot.create(:bas_charge, organization: organization) }
  let!(:charge_category_headers) do
    %w[fee_code
      fee_name
      internal_code].map(&:upcase)
  end
  let!(:charge_category_row) do
    [
      "BAS",
      "Basic Ocean Freight",
      nil
    ]
  end

  describe ".perform" do
    it "creates the routes" do
      result = described_class.write_document(
        organization: organization, user: user, file_name: "test.xlsx", options: {}
      )
      xlsx = Roo::Excelx.new(StringIO.new(result.file.download))
      first_sheet = xlsx.sheet(xlsx.sheets.first)
      expect(first_sheet.row(1)).to eq(charge_category_headers)
      expect(first_sheet.row(2)).to eq(charge_category_row)
    end
  end
end
