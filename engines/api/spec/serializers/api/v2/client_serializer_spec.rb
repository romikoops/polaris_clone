# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ClientSerializer do
    let(:client) { FactoryBot.create(:users_client) }
    let(:decorated_client) { Api::V2::ClientDecorator.new(client) }
    let(:serialized_client) { described_class.new(decorated_client).serializable_hash }
    let(:target) { serialized_client.dig(:data, :attributes) }
    let(:company) { FactoryBot.create(:companies_company, organization: client.organization) }
    let(:expected_serialized_client) do
      {
        email: client.email,
        organizationId: client.organization_id,
        firstName: client.profile.first_name,
        lastName: client.profile.last_name,
        companyName: company.name,
        phone: client.profile.phone
      }
    end

    before { FactoryBot.create(:companies_membership, client: client, company: company) }

    it "returns the correct origin name for the object passed" do
      expect(target).to eq(expected_serialized_client)
    end
  end
end
