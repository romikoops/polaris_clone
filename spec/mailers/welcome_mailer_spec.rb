# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeMailer do
  let(:user) { FactoryBot.create(:organizations_user) }
  let(:organization) { user.organization }
  let(:profile) { FactoryBot.build(:profiles_profile) }

  before do
    FactoryBot.create(:legacy_content,
      component: "WelcomeMail", section: "subject", text: "WELCOME_EMAIL", organization_id: organization.id)
    FactoryBot.create(:legacy_content,
      component: "WelcomeMail", section: "body", text: "WELCOME_EMAIL", organization_id: organization.id)
    FactoryBot.create(:legacy_content,
      component: "WelcomeMail", section: "social", text: "WELCOME_EMAIL", organization_id: organization.id)
    FactoryBot.create(:legacy_content,
      component: "WelcomeMail", section: "footer", text: "WELCOME_EMAIL", organization_id: organization.id)

    stub_request(:get, "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://assets.itsmycargo.com/assets/tenants/normanglobal/ngl_welcome_image.jpg")
      .to_return(status: 200, body: "", headers: {})
    allow(Profiles::ProfileService).to receive(:fetch).and_return(Profiles::ProfileDecorator.new(profile))
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe "welcome_email", :aggregate_failures do
    let(:mail) do
      described_class.welcome_email(user)
    end

    it "renders correctly" do
      expect(mail.subject).to eq("WELCOME_EMAIL")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(["support@demo.com"])
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match("WELCOME_EMAIL")
    end
  end
end
