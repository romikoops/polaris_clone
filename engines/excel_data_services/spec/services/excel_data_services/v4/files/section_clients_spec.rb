# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Section do
  include_context "V4 setup"

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
      expect(service.perform).to be_a(ExcelDataServices::V4::State)
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
