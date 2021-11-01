# frozen_string_literal: true

require "rails_helper"

module Companies
  RSpec.describe CompanyServices, type: :class do
    subject(:company_service) { described_class.new(company: company) }

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user_client) { FactoryBot.create(:users_client, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:company_membership) { FactoryBot.create(:companies_membership, company: company, client: user_client) }
    let(:group_membership) { FactoryBot.create(:groups_membership, group: group, member: company) }
    let(:default_company) { FactoryBot.create(:companies_company, name: "default", organization: organization) }
    let(:group) do
      FactoryBot.create(:groups_group, organization: organization, name: "Test").tap do |grp|
        FactoryBot.create(:groups_membership, group: grp, member: user_client)
      end
    end

    before do
      ::Organizations.current_id = organization.id
    end

    it "initializes a valid company membership object" do
      expect(company_service).to be_present
    end

    shared_examples_for "clients assigned to default company" do
      let(:default_company_membership) { Companies::Membership.where(client_id: user_client.id, company_id: default_company.id) }
      it "clients company membership is associated to default company" do
        expect(default_company_membership).to be_present
      end
    end

    shared_examples_for "companies membership destroyed" do
      let(:company_membership_query) { Companies::Membership.where(client_id: user_client.id, company_id: company.id) }
      it "company membership soft deleted" do
        company_membership.reload
        expect(company_membership.deleted?).to be true
      end

      it "company membership cannot be found" do
        expect(company_membership_query).to be_empty
      end
    end

    shared_examples_for "groups membership destroyed" do
      let(:group_membership_query) { Groups::Membership.where(member_id: company.id) }
      it "group membership soft deleted" do
        group_membership.reload
        expect(group_membership.deleted?).to be true
      end

      it "group membership cannot be found" do
        expect(group_membership_query).to be_empty
      end
    end

    describe "#destroy" do
      before do
        company_membership
        group_membership
        default_company
      end

      it "raises exception when company is not present" do
        expect { described_class.new(company: nil).destroy }.to raise_error(Companies::CompanyServices::InvalidCompany)
      end

      context "when destroy is called on company service with valid company" do
        before { company_service.destroy }

        it_behaves_like "companies membership destroyed"
        it_behaves_like "clients assigned to default company"
        it_behaves_like "groups membership destroyed"
      end

      context "when destroying a company fails" do
        subject(:company_service_destroy) { company_service.destroy }

        before do
          allow(company).to receive(:destroy).and_raise(StandardError)
        end

        it "company membership is present" do
          company_membership.reload
          expect(company_membership.deleted?).to be false
        end

        it "group membership is present" do
          group_membership.reload
          expect(group_membership.deleted?).to be false
        end

        it "clients are not assigned subscription to default company" do
          expect(Companies::Membership.where(client_id: user_client.id, company_id: company.id)).to be_present
        end
      end
    end
  end
end
