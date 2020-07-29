# frozen_string_literal: true

require "rails_helper"

RSpec.describe UploadMailer, type: :mailer do
  let(:user) { create(:organizations_user) }
  let(:user.organization) { user.organization }

  before do
    stub_request(:get, "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png").to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png").to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})
  end

  describe "complete_mail" do
    let(:mail) {
      described_class.with(
        user_id: user.id,
        organization: organization,
        result: {"errors" => []},
        file: "test.xlsx"
      ).complete_email
    }

    it "renders", :aggregate_failures do
      expect(mail.subject).to eq("[#{organization.slug}] test.xlsx uploaded successfully")
      expect(mail.from).to eq(["notifications@itsmycargo.shop"])
      expect(mail.to).to eq([user.email])
    end
  end
end
