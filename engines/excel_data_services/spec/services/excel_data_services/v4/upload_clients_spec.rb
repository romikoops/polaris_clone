# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:xlsx) { File.open(file_fixture("excel/example_clients.xlsx")) }

  before do
    %w[EUR USD].each do |currency|
      FactoryBot.create(:treasury_exchange_rate, to: currency)
    end
  end

  describe "#perform" do
    let(:result_stats) { service.perform }

    it "populates the errors, with a message that indicates a user already exists" do
      client = FactoryBot.create(:users_client, email: "user1@itsmycargo.test", organization: organization)
      expect(result_stats[:errors].map(&:reason)).to include("The client '#{client.email}' already exists.")
    end

    it "creates 4 users clients, when the data in the spreadsheet is valid" do
      service.perform
      expect(Users::Client.count).to eq 4
    end

    context "when the sheet contains an invalid language" do
      let(:xlsx) { File.open(file_fixture("excel/example_clients_invalid_language.xlsx")) }

      it "populates the errors, with a message indicating the language is not one of en-US, es-ES and de-DE" do
        expect(result_stats[:errors].map(&:reason)).to include("The language 'en-FOO' is not one of en-US, de-DE, es-ES")
      end
    end

    context "when the sheet contains an invalid currency" do
      let(:xlsx) { File.open(file_fixture("excel/example_clients_invalid_currency.xlsx")) }

      it "populates the errors, with a message indicating the currency is not a valid one under the ISO4217 standard" do
        expect(result_stats[:errors].map(&:reason)).to include("The currency 'FOO' is not valid under the ISO4217 standard")
      end
    end
  end

  describe "#valid?" do
    context "with an empty sheet" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "with an clients sheet" do
      let(:xlsx) { File.open(file_fixture("excel/example_clients.xlsx")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
