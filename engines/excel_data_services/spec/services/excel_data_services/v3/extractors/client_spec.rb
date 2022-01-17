# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Extractors::Client do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:users_client) { FactoryBot.create(:users_client, organization: organization) }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "email" => users_client.email,
          "company_name" => company.name,
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the user id" do
        expect(extracted_table["user_id"].to_a).to eq([users_client.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "company_name" => "AAA",
          "first_name" => 2,
          "last_name" => "AAA",
          "email" => 2,
          "phone" => "AAA",
          "external_id" => 2,
          "password" => "AAA",
          "currency" => 2,
          "language" => 2,
          "user_id" => nil
        }
      end

      it "does not find the record or add a company" do
        expect(extracted_table["user_id"].to_a).to eq([nil])
      end
    end
  end
end
