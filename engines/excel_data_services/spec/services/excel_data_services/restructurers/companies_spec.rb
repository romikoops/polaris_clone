# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::Companies do
  describe ".perform" do
    let(:data) do
      { sheet_name: "Sheet1",
        restructurer_name: "companies",
        rows_data: [{
          name: "Test Company",
          email: "test@company.com",
          phone: "1234567879",
          vat_number: "987654321",
          external_id: "abcde",
          address: "Brooktorkai 7, 20457, Hamburg, Germany",
          payment_terms: "Show me the money!"
        }] }
    end
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:result) { described_class.restructure(organization: organization, data: data) }

    before do
      allow(Legacy::Address).to receive(:geocoded_address).and_return(instance_double("Legacy::Address", id: 1))
    end

    it "extracts the row data from the sheet hash", :aggregate_failures do
      expect(result["Companies"]).to match_array(data[:rows_data])
      expect(result["Companies"].first[:address_id]).to eq(1)
    end
  end
end
