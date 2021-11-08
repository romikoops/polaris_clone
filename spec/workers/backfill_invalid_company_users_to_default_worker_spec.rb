# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillInvalidCompanyUsersToDefaultWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:default_company) { FactoryBot.create(:companies_company, name: "default", organization: organization) }
  let!(:company_with_empty_name_ext_id) { FactoryBot.create(:companies_company, name: "", external_id: "", organization: organization) }
  let!(:company_with_empty_name) { FactoryBot.create(:companies_company, name: "", organization: organization) }
  let!(:user_client_belong_to_empty_company) { FactoryBot.create(:users_client, organization: organization) }
  let!(:company_membership) { FactoryBot.create(:companies_membership, company: company_with_empty_name_ext_id, client: user_client_belong_to_empty_company) }

  before do
    ::Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "when backfill is successul" do
      before do
        described_class.new.perform
      end

      it "company with empty name will have external id assigned as name" do
        company_with_empty_name.reload
        expect(company_with_empty_name.name).to eq company_with_empty_name.external_id
      end

      it "company with empty name and empty external id will be soft deleted" do
        company_with_empty_name_ext_id.reload
        expect(company_with_empty_name_ext_id.deleted?).to eq true
      end

      it "company membership is soft deleted" do
        company_membership.reload
        expect(company_membership.deleted?).to eq true
      end

      it "user client is subscribed to default company" do
        expect(Companies::Membership.where(client_id: user_client_belong_to_empty_company.id, company_id: default_company.id)).to be_present
      end
    end

    context "when backfill fails" do
      let!(:backfill_company_instance) { described_class.new }

      before do
        allow(backfill_company_instance).to receive(:companies_with_blank_name) { [company_with_empty_name_ext_id] }
      end

      it "raises `FailedCompanyBackFill` error" do
        expect { backfill_company_instance.perform }.to raise_error(BackfillInvalidCompanyUsersToDefaultWorker::FailedCompanyBackFill)
      end
    end
  end
end
