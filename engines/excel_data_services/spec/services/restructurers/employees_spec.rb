# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::Companies do
  describe ".perform" do
    let(:data) do
      {sheet_name: "Sheet1",
       restructurer_name: "employees",
       rows_data: [{
         first_name: "Test",
         last_name: "Agent",
         email: "TEST@company.com",
         phone: "1234567879",
         company_name: company.name,
         vat_number: "987654321",
         external_id: "abcde",
         address: "Brooktorkai 7, 20457, Hamburg, Germany",
         password: "123456789 "
       }]}
    end
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:result) { described_class.restructure(organization: organization, data: data) }
    let(:restructured_employee) { result["Employees"].first }
    let(:expected_result) do
      [{
        first_name: "Test",
        last_name: "Agent",
        email: "test@company.com",
        phone: "1234567879",
        company_name: company.name,
        company: company,
        vat_number: "987654321",
        external_id: "abcde",
        address: "Brooktorkai 7, 20457, Hamburg, Germany",
        password: "123456789",
        address_id: 1
      }]
    end

    before do
      address = instance_double("Legacy::Address", id: 1)
      allow(Legacy::Address).to receive(:geocoded_address).and_return(address)
    end

    it "extracts the row data from the sheet hash" do
      aggregate_failures do
        expect(result).to eq("Employees" => expected_result)
      end
    end
  end
end
