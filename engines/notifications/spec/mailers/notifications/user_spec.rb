# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe UserMailer, type: :mailer do
    let(:organization) { FactoryBot.build(:organizations_organization) }

    describe "activation_needed_email" do
      let(:mail) do
        described_class.with(
          organization: organization,
          user: user
        ).activation_needed_email
      end

      shared_examples_for "activation_needed_email" do
        it "renders the headers" do
          aggregate_failures do
            expect(mail.subject).to eq("[#{organization.theme.name}] Confirm Your Account")
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
          end
        end

        it "renders the body" do
          expect(mail.body.encoded).to match("Hello #{user.profile.name}")
        end
      end

      context "when user is a Users::User" do
        let(:user) { FactoryBot.build(:users_user) }

        it_behaves_like "activation_needed_email"
      end

      context "when user is a Users::Client" do
        let(:user) { FactoryBot.build(:users_client, organization: organization) }

        it_behaves_like "activation_needed_email"
      end
    end

    describe "reset_password_email" do
      let(:mail) do
        described_class.with(
          organization: organization,
          user: user
        ).reset_password_email
      end

      shared_examples_for "reset_password_email" do
        it "renders the headers" do
          aggregate_failures do
            expect(mail.subject).to eq("[#{organization.theme.name}] Reset Password")
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
          end
        end

        it "renders the body" do
          expect(mail.body.encoded).to match("Hello #{user.profile.name}")
        end
      end

      context "when user is a Users::User" do
        let(:user) { FactoryBot.build(:users_user) }

        it_behaves_like "reset_password_email"
      end

      context "when user is a Users::Client" do
        let(:user) { FactoryBot.build(:users_client, organization: organization) }

        it_behaves_like "reset_password_email"
      end
    end
  end
end
