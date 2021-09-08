# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserServices::CompanyMembership, type: :model do
  subject(:company_membership_service) { described_class.new(company: company) }

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:company) { FactoryBot.create(:companies_company) }

  before do
    ::Organizations.current_id = organization.id
  end

  it "initializes a valid company membership object" do
    expect(company_membership_service).to be_present
  end

  describe "#add_membership" do
    it "when users is not specified" do
      expect(company_membership_service.add_membership(users: nil)).to be_nil
    end

    context "when company memberships exists for the specified users" do
      let(:user) { FactoryBot.create(:user_services_client, organization: organization) }
      let(:company) { user.company_membership.company }

      it "existing membership is present" do
        company_membership_service.add_membership(users: [user.id])
        expect(user.company_membership).to be_present
      end
    end

    context "when company memberships is soft deleted for the specified users" do
      let(:user) { FactoryBot.create(:user_services_client, organization: organization) }
      let(:company) { user.company_membership.company }

      it "new membership is not created, old membership is restored" do
        user.company_membership.destroy
        company_membership_service.add_membership(users: [user.id])
        expect(user.company_membership.reload.deleted_at).to be_nil
      end
    end

    context "when company memberships is not present for the specified users" do
      let(:user) { FactoryBot.create(:user_services_client, organization: organization) }
      let(:company) { FactoryBot.create(:companies_company, name: "test_comp", organization: organization) }

      it "new membership is created and associated to users" do
        company_membership_service.add_membership(users: [user.id])
        expect(user.company_membership.company).to eq company
      end
    end
  end
end
