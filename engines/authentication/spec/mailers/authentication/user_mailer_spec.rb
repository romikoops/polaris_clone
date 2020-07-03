# frozen_string_literal: true

require "rails_helper"

RSpec.describe Authentication::UserMailer, type: :mailer do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "demo") }
  let(:user) do
    double("User", email: "john@itsmycargo.test", organization_id: organization.id,
                   activation_token: "ACTIVATION_TOKEN", reset_password_token: "RESET_TOKEN")
  end

  before do
    stub_request(:get, "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png").to_return(status: 200)
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png").to_return(status: 200)
    FactoryBot.create(:organizations_theme, organization: organization, name: "Demo")
    FactoryBot.create(:organizations_domain, default: true, organization: organization, domain: "demo")
    allow(Rails).to receive("env").and_return("production")
  end

  describe "confirmation_instructions" do
    let(:mail) do
      described_class.activation_needed_email(user)
    end

    it "renders the correct subject" do
      expect(mail.subject).to eq("Demo Account Confirmation Email")
    end

    it "renders the correct sender" do
      expect(mail.from).to eq(["no-reply@demo.itsmycargo.shop"])
      expect(mail.reply_to).to eq(["support@demo.com"])
    end

    it "renders the correct receiver" do
      expect(mail.to).to eq([user.email])
    end

    it "assigns @confirmation_url" do
      expect(mail.body.encoded).to match("/confirmation/ACTIVATION_TOKEN")
    end

    it "renders a body with the correct text" do
      expect(mail.body.encoded).to match("Thank you for registering")
    end
  end

  describe "activation_success_email" do
    let(:mail) do
      described_class.activation_success_email(user)
    end

    it "renders the correct subject" do
      expect(mail.subject).to eq("Activation success email")
    end
  end

  describe "reset_password_instructions" do
    let(:mail) do
      described_class.reset_password_email(user)
    end

    it "renders the correct subject" do
      expect(mail.subject).to eq("Demo Account Password Reset")
    end

    it "renders the correct sender" do
      expect(mail.from).to eq(["no-reply@demo.itsmycargo.shop"])
      expect(mail.reply_to).to eq(["support@demo.com"])
    end

    it "renders the correct receiver" do
      expect(mail.to).to eq([user.email])
    end

    it "renders a body with the correct text" do
      expect(mail.html_part.body).to match("Change my password")
    end

    context "when env is development" do
      before do
        allow(Rails).to receive("env").and_return("development")
      end

      it "assigns @confirmation_url" do
        expect(mail.body.encoded).to match("http://localhost:8080/")
      end
    end

    context "when env is review" do
      before do
        allow(Rails).to receive("env").and_return("review")
        ENV["REVIEW_URL"] = "review_domain"
      end

      it "assigns @confirmation_url" do
        expect(mail.body.encoded).to match(ENV["REVIEW_URL"])
      end
    end

    context "when env is test" do
      before do
        allow(Rails).to receive("env").and_return("test")
      end

      it "assigns @confirmation_url" do
        expect(mail.body.encoded).to match("http://localhost:8080/")
      end
    end
  end
end
