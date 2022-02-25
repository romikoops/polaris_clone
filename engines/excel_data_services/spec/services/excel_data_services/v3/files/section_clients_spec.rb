# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Section do
  include_context "V3 setup"

  let(:xlsx) { File.open(file_fixture("excel/example_clients.xlsx")) }
  let(:section_string) { "Clients" }
  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }

  before { FactoryBot.create(:treasury_exchange_rate) }

  describe "#valid?" do
    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#framed_data" do
    let(:expected_results) do
      [{"company_name"=>"Test Company",
        "first_name"=>"User 1",
        "last_name"=>"Test",
        "email"=>"user1@itsmycargo.test",
        "phone"=>"123456789.0",
        "external_id"=>nil,
        "password"=>"TEST1234",
        "currency"=>"EUR",
        "language"=>"en-US",
        "sheet_name"=>"Agents",
        "organization_id"=> organization.id,
        "row"=>2},
       {"company_name"=>"Test Company",
        "first_name"=>"User 2",
        "last_name"=>"Test",
        "email"=>"user2@itsmycargo.test",
        "phone"=>"987654321.0",
        "external_id"=>nil,
        "password"=>"TEST1235",
        "currency"=>"EUR",
        "language"=>"de-DE",
        "sheet_name"=>"Agents",
        "organization_id"=> organization.id,
        "row"=>3},
       {"company_name"=>"Test Company",
        "first_name"=>"User 3",
        "last_name"=>"Test",
        "email"=>"user3@itsmycargo.test",
        "phone"=>nil,
        "external_id"=>"235.0",
        "password"=>"TEST1236",
        "currency"=>"USD",
        "language"=>"es-ES",
        "sheet_name"=>"Agents",
        "organization_id"=> organization.id,
        "row"=>4},
       {"company_name"=>"Test Company",
        "first_name"=>"User 4",
        "last_name"=>"Test",
        "email"=>"user4@itsmycargo.test",
        "phone"=>nil,
        "external_id"=>"556.0",
        "password"=>"TEST1237",
        "currency"=>nil,
        "language"=>"en-US",
        "sheet_name"=>"Agents",
        "organization_id"=> organization.id,
        "row"=>5}]
    end

    it "returns a DataFrame of extracted values" do
      expect(service.framed_data).to eq(Rover::DataFrame.new(expected_results))
    end
  end

  describe "#perform" do
    before do
      %w[EUR USD].each do |currency|
        FactoryBot.create(:treasury_exchange_rate, to: currency)
      end
    end

    it "populates the errors, with a message that indicates a user already exists" do
      client = FactoryBot.create(:users_client, email: "user1@itsmycargo.test", organization: organization)
      expect(service.perform.errors.map(&:reason)).to include("The client '#{client.email}' already exists.")
    end

    it "returns a State object after inserting Data", :aggregate_failures do
      expect(service.perform).to be_a(ExcelDataServices::V3::State)
    end

    it "creates 4 users clients, when the data in the spreadsheet is valid" do
      service.perform
      expect(Users::Client.count).to eq 4
    end

    context "when the sheet contains an invalid language" do
      let(:xlsx) { File.open(file_fixture("excel/example_clients_invalid_language.xlsx")) }

      it "populates the errors, with a message indicating the language is not one of en-US, es-ES and de-DE" do
        expect(service.perform.errors.map(&:reason)).to include("The language 'en-FOO' is not one of en-US, de-DE, es-ES")
      end
    end

    context "when the sheet contains an invalid currency" do
      let(:xlsx) { File.open(file_fixture("excel/example_clients_invalid_currency.xlsx")) }

      it "populates the errors, with a message indicating the currency is not a valid one under the ISO4217 standard" do
        expect(service.perform.errors.map(&:reason)).to include("The currency 'FOO' is not valid under the ISO4217 standard")
      end
    end
  end
end
