# frozen_string_literal: true

require "rails_helper"
RSpec.describe RemoveMultipleMembershipsBelongingToOneUserWorker, type: :worker do
  describe "#perform" do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:users_client) { FactoryBot.create(:users_client, organization: organization) }
    let!(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let!(:default_company) { FactoryBot.create(:companies_company, organization: organization, name: "default") }

    it "soft deletes a default company's memberships for a given organization" do
      FactoryBot.create(:companies_membership, company: default_company, member: users_client)
      users_client_two = FactoryBot.create(:users_client, organization: organization)
      FactoryBot.create(:companies_membership, company: company, member: users_client_two)
      FactoryBot.create(:companies_membership, company: default_company, member: users_client_two)

      expect { described_class.new.perform }.to change { default_company.memberships.count }.from(2).to(1)
    end

    it "soft deletes a company's memberships, where duplicates are present" do
      FactoryBot.create(:companies_company, organization: organization, name: "default")
      FactoryBot.create(:companies_membership, company: FactoryBot.create(:companies_company, organization: organization), member: users_client)
      membership_two = FactoryBot.create(:companies_membership, company: company, member: users_client, created_at: 5.minutes.ago)

      expect { described_class.new.perform }.to change { Companies::Membership.with_deleted.find(membership_two.id).deleted? }.from(false).to(true)
    end
  end
end
