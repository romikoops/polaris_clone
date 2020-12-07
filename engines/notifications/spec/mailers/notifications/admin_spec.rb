require "rails_helper"

module Notifications
  RSpec.describe AdminMailer, type: :mailer do
    describe "user_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
      let(:profile) { FactoryBot.create(:profiles_profile, user: user) }

      let(:mail) do
        AdminMailer.with(
          organization: organization,
          user: user,
          profile: profile,
          recipient: "to@example.org"
        ).user_created
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to eq("[ItsMyCargo] New User Registered")
          expect(mail.to).to eq(["to@example.org"])
          expect(mail.from).to eq(["support@itsmycargo.com"])
        end
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end
    end
  end
end
