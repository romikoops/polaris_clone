# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Employees do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, data: input_data, options: {}} }
  let(:input_data) do
    [row]
  end
  let(:stats) { described_class.insert(options) }

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
  end

  describe ".insert" do
    context "with valid data" do
      let(:row) {
        {
          first_name: "Test",
          last_name: "User",
          email: "testuser@itsmycargo.com",
          password: "password",
          phone: "123456789",
          row_nr: 1
        }
      }
      it "inserts correctly and returns correct stats" do
        expect(stats[:'users/clients'][:number_created]).to eq(1)
      end
    end

    context "with invalid data" do
      let(:row) {
        {
          first_name: "Test",
          last_name: "User",
          email: "testuser@itsmycargo.com  ",  # Invalid due to &nbsp; - Restructurer would remove this
          password: "password",
          phone: "123456789",
          row_nr: 1
        }
      }
      it "returns the correct errors" do
        expect(stats[:errors]).to eq([
          {
            reason: "Email is invalid",
            row_nr: 1,
            sheet_name: nil
          }
        ])
      end
    end
  end
end
