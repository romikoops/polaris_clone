# frozen_string_literal: true

require "rails_helper"
RSpec.describe DedupeCompaniesWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:invalid_email_company) { FactoryBot.build(:companies_company, email: "x").tap { |invalid_company| invalid_company.save(validate: false) } }
  let(:original_company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:duplicate_company) { FactoryBot.build(:companies_company, name: original_company.name, external_id: "test_id", organization: organization).tap { |invalid_company| invalid_company.save(validate: false) } }
  let(:offcase_duplicate_company) { FactoryBot.create(:companies_company, name: original_company.name.upcase, organization: organization) }
  let!(:duplicate_membership) { FactoryBot.create(:companies_membership, company: duplicate_company, client: FactoryBot.create(:users_client, organization: organization)) }
  let!(:offcase_duplicate_membership) { FactoryBot.create(:companies_membership, company: offcase_duplicate_company, client: FactoryBot.create(:users_client, organization: organization)) }
  let!(:shipment_request) { FactoryBot.create(:journey_shipment_request, company: duplicate_company) }
  let!(:query) { FactoryBot.create(:journey_query, company: duplicate_company, organization: organization) }
  let!(:duplicate_group_membership) { FactoryBot.create(:groups_membership, member: duplicate_company, group: FactoryBot.build(:groups_group)) }

  describe "#perform" do
    before do
      described_class.new.perform
    end

    it "nullifies the invalid email" do
      expect(invalid_email_company.reload.email).to be_nil
    end

    it "moves the memberships from the duplicates to the original Company", :aggregate_failures do
      expect(duplicate_membership.reload.company).to eq(original_company)
      expect(offcase_duplicate_membership.reload.company).to eq(original_company)
    end

    it "moves the associated models from the duplicates to the original Company", :aggregate_failures do
      expect(shipment_request.reload.company).to eq(original_company)
      expect(query.reload.company).to eq(original_company)
      expect(duplicate_group_membership.reload.member).to eq(original_company)
    end

    it "deletes the duplicated Companies", :aggregate_failures do
      expect(Companies::Company.only_deleted.find(duplicate_company.id)).to be_present
      expect(Companies::Company.only_deleted.find(offcase_duplicate_company.id)).to be_present
    end
  end
end
