# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillNonMemberClientsToDefaultCompanyMembershipWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user_client) { FactoryBot.create(:users_client, organization: organization) }
  let!(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let!(:company_membership) { FactoryBot.create(:companies_membership, company: company, client: user_client) }
  let!(:default_company) { FactoryBot.create(:companies_company, name: "default", organization: organization) }

  before do
    ::Organizations.current_id = organization.id
  end

  describe "#perform" do
    before do
      company.update(deleted_at: 2.days.ago)
    end

    context "when company membership is present but company is deleted" do
      before do
        described_class.new.perform
      end

      it "company membership is soft deleted" do
        company_membership.reload
        expect(company_membership.deleted?).to be true
      end

      it "user client is subscribed to default company" do
        expect(Companies::Membership.where(client_id: user_client.id, company_id: default_company.id)).to be_present
      end
    end
  end
end
