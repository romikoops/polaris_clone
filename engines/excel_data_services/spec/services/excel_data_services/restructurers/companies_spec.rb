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
          address: "Brooktorkai 7, 20457, Hamburg, Germany"
        }] }
    end
    let(:organization) { FactoryBot.create(:organizations_organization) }

    before do
      address = instance_double("Legacy::Address", id: 1)
      allow(Legacy::Address).to receive(:geocoded_address).and_return(address)
    end

    it "extracts the row data from the sheet hash" do
      result = described_class.restructure(organization: organization, data: data)
      aggregate_failures do
        expect(result).to eq("Companies" => data[:rows_data])
        expect(result["Companies"].length).to be(1)
        expect(result.class).to be(Hash)
        expect(result["Companies"].first[:address_id]).to eq(1)
      end
    end
  end
end
