# frozen_string_literal: true
require "rails_helper"

module Companies
  RSpec.describe Membership, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }

    it "builds a valid company" do
      expect(company).to be_valid
    end
  end
end
