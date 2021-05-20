# frozen_string_literal: true

require "rails_helper"

RSpec.describe CorrectLclSacoBillableWorker, type: :worker do
  describe ".perform" do
    let!(:organization) { FactoryBot.create(:organizations_organization, slug: "lclsaco", scope: scope) }
    let(:scope) { FactoryBot.build(:organizations_scope, content: { blacklisted_emails: ["blacklistedemail@itsmycargo.test"] }) }
    let(:user) { FactoryBot.create(:users_client, email: "blacklistedemail@itsmycargo.test", organization: organization) }
    let!(:needs_updating) { FactoryBot.create(:journey_query, organization: organization, billable: false) }
    let!(:skipped_by_date) { FactoryBot.create(:journey_query, organization: organization, billable: false, created_at: DateTime.parse("2019/12/30")) }
    let!(:skipped_by_user) { FactoryBot.create(:journey_query, organization: organization, billable: false, client: user) }
    let!(:skipped_by_result_set) { FactoryBot.create(:journey_query, organization: organization, billable: false) }

    before do
      FactoryBot.create(:journey_result_set, query: needs_updating, status: "completed")
      FactoryBot.create(:journey_result_set, query: skipped_by_user, status: "completed")
      FactoryBot.create(:journey_result_set, query: skipped_by_user, status: "completed")
      FactoryBot.create(:journey_result_set, query: skipped_by_result_set, status: "failed")
      described_class.new.perform
    end

    it "updates only the Queries that should be, based on date and client", :aggregate_failures do
      expect(needs_updating.reload.billable).to be_present
      expect(skipped_by_date.reload.billable).not_to be_present
      expect(skipped_by_user.reload.billable).not_to be_present
      expect(skipped_by_result_set.reload.billable).not_to be_present
    end
  end
end
