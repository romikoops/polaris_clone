# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe DownloadMailer, type: :mailer do
    describe "#complete_email" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:user) { FactoryBot.create(:users_client, organization: organization) }
      let(:category_identifier) { "hubs" }
      let(:file_name) { "test_file_name" }
      let(:bcc) { [] }
      let(:mail) do
        described_class.with(
          organization: organization,
          user: user,
          result: result,
          file_name: file_name,
          category_identifier: category_identifier,
          bcc: bcc
        ).complete_email
      end

      let(:document) { FactoryBot.create(:legacy_file, :with_file, text: file_name) }
      let(:errors) { [] }

      let(:result) do
        {
          document: document,
          errors: errors,
          can_attach: true
        }
      end

      context "with success result" do
        it "renders the correct subject and addresses" do
          aggregate_failures do
            expect(mail.subject).to eq("[ItsMyCargo] : #{category_identifier} sheet for download is ready")
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["notifications@itsmycargo.shop"])
          end
        end

        context "when can_attach is true" do
          it "renders the body with the message that the sheet is attached" do
            expect(mail.html_part.body.to_s).to match("You can find the requested <b>#{category_identifier.humanize}</b> sheet attached to this email.")
          end

          it "renders the body with the message that the download link can also be used" do
            expect(mail.html_part.body.to_s).to match("However you can also download the sheet by clicking")
          end

          it "renders attaches the file and logo" do
            expect(mail.attachments.map(&:filename)).to match_array(["logo.png", "test_file_name"])
          end
        end

        context "when can_attach is false" do
          before { result[:can_attach] = false }

          it "renders the body with the message that the sheet is attached" do
            expect(mail.html_part.body.to_s).to match("Note: Sheet is too large to be attached to this email, it can only be downloaded by clicking the link above.")
          end

          it "renders the body with the message that the download link can also be used" do
            expect(mail.html_part.body.to_s).to match("You can download <b>#{category_identifier.humanize}</b> sheet by clicking")
          end

          it "renders attaches the file and logo" do
            expect(mail.attachments.map(&:filename)).to match_array(["logo.png"])
          end
        end
      end

      context "with error result" do
        let(:errors) do
          [{
            sheet_name: file_name,
            reason: <<-STRING.squish
              We are sorry, but something has gone wrong while generating file
              #{file_name}. The Operations Team has been
              notified of the error.
            STRING
          }]
        end

        let(:bcc) { ["ops@itsmycargo.com"] }

        it "renders the correct subject and addresses" do
          aggregate_failures do
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["notifications@itsmycargo.shop"])
            expect(mail.bcc).to eq(["ops@itsmycargo.com"])
          end
        end

        it "renders the body with the error reason" do
          expect(mail.html_part.body.to_s).to match(errors.first[:reason])
        end
      end
    end
  end
end
