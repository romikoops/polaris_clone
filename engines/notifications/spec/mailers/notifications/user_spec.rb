# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe UserMailer, type: :mailer do
    let(:organization) { FactoryBot.build(:organizations_organization) }
    let(:user) { FactoryBot.build(:users_user) }

    describe "activation_needed_email" do
      let(:mail) do
        described_class.with(
          organization: organization,
          user: user
        ).activation_needed_email
      end

      it "renders the headers", :aggregate_failures do
        expect(mail.subject).to eq("[ItsMyCargo] Confirm Your Account")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hello #{user.profile.name}")
      end
    end

    describe "reset_password_email" do
      let(:mail) do
        described_class.with(
          organization: organization,
          user: user
        ).reset_password_email
      end

      it "renders the headers", :aggregate_failures do
        expect(mail.subject).to eq("[ItsMyCargo] Reset Password")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hello #{user.profile.name}")
      end
    end
  end
end
