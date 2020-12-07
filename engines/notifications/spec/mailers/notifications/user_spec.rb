require "rails_helper"

module Notifications
  RSpec.describe UserMailer, type: :mailer do
    let(:organization) { FactoryBot.build(:organizations_organization) }
    let(:user) { FactoryBot.build(:organizations_user, organization: organization) }
    let(:profile) { FactoryBot.build(:profiles_profile, user: user) }

    describe "activation_needed_email" do
      let(:mail) do
        UserMailer.with(
          organization: organization,
          user: user,
          profile: profile
        ).activation_needed_email
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to eq("[#{organization.theme.name}] Confirm Your Account")
          expect(mail.to).to eq([user.email])
          expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
        end
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hello #{profile.full_name}")
      end
    end

    describe "reset_password_email" do
      let(:mail) do
        UserMailer.with(
          organization: organization,
          user: user,
          profile: profile
        ).reset_password_email
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to eq("[#{organization.theme.name}] Reset Password")
          expect(mail.to).to eq([user.email])
          expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
        end
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hello #{profile.full_name}")
      end
    end
  end
end
