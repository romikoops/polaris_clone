# frozen_string_literal: true

require "rails_helper"

RSpec.describe UploadMailer, type: :mailer do
  let(:user) { FactoryBot.create(:users_user) }
  let(:mail) do
    described_class.with(arguments).complete_email
  end

  before do
    stub_request(:get, "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
  end

  describe "complete_mail" do
    let(:arguments) do
      {
        user_id: user.id,
        result: { "errors" => [] },
        file: "test.xlsx"
      }
    end

    it "renders", :aggregate_failures do
      expect(mail.subject).to eq("[ItsMyCargo] test.xlsx uploaded successfully")
      expect(mail.from).to eq(["notifications@itsmycargo.shop"])
      expect(mail.to).to eq([user.email])
    end

    context "with blind copy" do
      let(:arguments) do
        {
          user_id: user.id,
          result: { "errors" => [] },
          file: "test.xlsx",
          bcc: ["test-ops@itsmycargo.test"]
        }
      end

      it "renders", :aggregate_failures do
        expect(mail.subject).to eq("[ItsMyCargo] test.xlsx uploaded successfully")
        expect(mail.from).to eq(["notifications@itsmycargo.shop"])
        expect(mail.to).to eq([user.email])
        expect(mail.bcc).to eq(["test-ops@itsmycargo.test"])
      end
    end

    context "with missing result" do
      let(:arguments) do
        {
          user_id: user.id,
          result: nil,
          file: "test.xlsx",
          bcc: ["test-ops@itsmycargo.test"]
        }
      end

      it "renders", :aggregate_failures do
        expect(mail.subject).to eq("[ItsMyCargo] test.xlsx uploaded with errors")
        expect(mail.from).to eq(["notifications@itsmycargo.shop"])
        expect(mail.to).to eq([user.email])
        expect(mail.bcc).to eq(["test-ops@itsmycargo.test"])
      end
    end
  end
end
