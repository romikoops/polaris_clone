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

    describe ".offer_email" do
      it "returns the headers", :aggregate_failures do
        journey_offer = FactoryBot.create(:journey_offer)
        mail = offer_email(offer: journey_offer)
        expect(mail.subject).to eq("LCL Quotation: 20457, Hamburg - Shanghai Airport, Refs: #{journey_offer.line_item_sets.first.reference}")
        expect(mail.to).to eq([client.email])
        expect(mail.from).to eq(["sales.general@demo.com"])
      end

      it "returns no-reply@itsmycargo.shop in the 'from' header, when mode of transport and general key is not present in the organization's theme's emails" do
        theme = FactoryBot.build(:organizations_theme)
        theme.emails["sales"] = {}
        mail = offer_email(organization: FactoryBot.build(:organizations_organization, theme: theme))
        expect(mail.from).to eq(["no-reply@itsmycargo.shop"])
      end

      it "returns new_ocean@sales.com in the 'from' header, when the mode of transport provided, matches a key in the organization's theme's emails" do
        theme = FactoryBot.build(:organizations_theme)
        theme.emails["sales"]["ocean"] = "new_ocean@sales.com"
        mail = offer_email(organization: FactoryBot.build(:organizations_organization, theme: theme))
        expect(mail.from).to eq(["new_ocean@sales.com"])
      end

      it "includes the offer as an attachment" do
        journey_offer = FactoryBot.create(:journey_offer)
        mail = offer_email(offer: journey_offer)
        expect(mail.attachments.last.filename).to eq("offer_#{journey_offer.id}.pdf")
      end

      def offer_email(organization: FactoryBot.build(:organizations_organization), offer: FactoryBot.create(:journey_offer))
        described_class.with(organization: organization, offer: offer, user: client).offer_email
      end
    end
  end
end
