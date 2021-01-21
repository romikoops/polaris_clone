require "rails_helper"

module Organizations
  RSpec.describe IntegrationToken, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:token) { FactoryBot.build(:organizations_integration_token, organization: organization) }

    it "builds a valid object" do
      expect(token).to be_valid
    end

    it "must have a scope" do
      expect(FactoryBot.build(:organizations_integration_token, scope: nil)).to be_invalid
    end

    it "must have a correct formatted scope" do
      expect(FactoryBot.build(:organizations_integration_token, scope: "123")).to be_invalid
    end

    it "must have a token" do
      expect(FactoryBot.build(:organizations_integration_token, token: nil)).to be_invalid
    end
  end
end
