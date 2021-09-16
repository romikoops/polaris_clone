# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe ClientMailer, type: :mailer do
    let(:organization) { FactoryBot.build(:organizations_organization) }
    let(:client) { FactoryBot.build(:users_client, organization: organization) }

    describe "activation_needed_email" do
      let(:mail) do
        described_class.with(
          organization: organization,
          user: client
        ).activation_needed_email
      end

      it "renders the headers", :aggregate_failures do
        expect(mail.subject).to eq("[#{organization.theme.name}] Confirm Your Account")
        expect(mail.to).to eq([client.email])
        expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hello #{client.profile.name}")
      end
    end

    describe "reset_password_email" do
      let(:mail) do
        described_class.with(
          organization: organization,
          user: client
        ).reset_password_email
      end

      it "renders the headers", :aggregate_failures do
        expect(mail.subject).to eq("[#{organization.theme.name}] Reset Password")
        expect(mail.to).to eq([client.email])
        expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hello #{client.profile.name}")
      end
    end
  end
end
