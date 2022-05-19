# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::ExistingClient do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "user_id" => users_client.id,
          "email" => users_client.email,
          "organization_id" => organization.id
        }
      end
      let!(:users_client) { FactoryBot.create(:users_client, organization: organization) }

      it "appends an error to the state when the user client already exists", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(["The client '#{users_client.email}' already exists."])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "user_id" => nil,
          "email" => "users1@itsmycargo.test",
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the email address" do
        expect(extracted_table["email"].to_a).to eq(["users1@itsmycargo.test"])
      end
    end
  end
end
