require "rails_helper"
RSpec.describe AddShopadminToScopeBlacklistedEmailsWorker, type: :worker do
  context "when organization scope has no blacklisted emails" do
    let(:organization) { FactoryBot.build(:organizations_organization) }
    let!(:scope) { FactoryBot.create(:organizations_scope, target: organization) }

    it "adds email to blacklist" do
      described_class.new.perform

      expect(organization.scope.content["blacklisted_emails"]).to include "shopadmin@itsmycargo.com"
    end
  end
end
