# frozen_string_literal: true
require "rails_helper"
RSpec.describe AddShopadminToScopeBlacklistedEmailsWorker, type: :worker do
  context "when organization scope has no blacklisted emails" do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:scope) { organization.scope.reload }

    it "adds email to blacklist" do
      described_class.new.perform

      expect(scope.content["blacklisted_emails"]).to include "shopadmin@itsmycargo.com"
    end
  end
end
