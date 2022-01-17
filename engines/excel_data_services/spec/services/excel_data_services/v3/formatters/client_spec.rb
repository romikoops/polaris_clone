# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::Client do
  include_context "V3 setup"

  describe "#insertable_data" do
    let(:rows) do
      [{
        "company_name" => "company1",
        "first_name" => "John",
        "last_name" => "Smith",
        "email" => "user2@itsmycargo.test",
        "phone" => "+4911223344",
        "external_id" => "EXT_ID12345",
        "password" => "client_password_123",
        "currency" => "eur",
        "language" => "en",
        "organization_id" => organization.id
      }]
    end
    let(:expected_data) do
      [{ "email" => "user2@itsmycargo.test",
         "organization_id" => organization.id,
         "password" => "client_password_123",
         "profile" => { "company_name" => "company1", "first_name" => "John", "last_name" => "Smith", "phone" => "+4911223344", "external_id" => "EXT_ID12345" },
         "settings" => { "currency" => "eur", "language" => "en" } }]
    end

    it "returns the formatted data" do
      expect(described_class.state(state: state_arguments).insertable_data).to match_array(expected_data)
    end
  end
end
