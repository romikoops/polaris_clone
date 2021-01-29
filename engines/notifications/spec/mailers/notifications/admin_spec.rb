require "rails_helper"

module Notifications
  RSpec.describe AdminMailer, type: :mailer do
    describe "user_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:user) { FactoryBot.create(:users_client, organization: organization) }

      let(:mail) do
        AdminMailer.with(
          organization: organization,
          user: user,
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

    describe "offer_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:query) { FactoryBot.build(:journey_query, organization: organization) }
      let(:offer) { FactoryBot.build(:journey_offer, query: query) }
      let(:mail) do
        AdminMailer.with(
          organization: organization,
          offer: offer,
          recipient: "to@example.org"
        ).offer_created
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to include("FCL Quotation")
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
