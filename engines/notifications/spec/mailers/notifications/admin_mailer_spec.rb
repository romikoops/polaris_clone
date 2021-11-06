# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe AdminMailer, type: :mailer do
    before { FactoryBot.create(:legacy_charge_categories, code: "cargo", organization: organization) }

    describe "user_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:user) { FactoryBot.create(:users_client, organization: organization) }

      let(:mail) do
        described_class.with(
          organization: organization,
          user: user,
          recipient: "to@example.org"
        ).user_created
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to eq("[ItsMyCargo] New User Registered")
          expect(mail.to).to eq(["to@example.org"])
          expect(mail.from).to eq(["support@itsmycargo.com"])
        end
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end
    end

    describe "offer_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:query) { FactoryBot.build(:journey_query, organization: organization) }
      let(:offer) { FactoryBot.create(:journey_offer, query: query) }
      let(:mail) do
        described_class.with(
          organization: organization,
          offer: offer,
          recipient: "to@example.org"
        ).offer_created
      end

      it "renders the headers", :aggregate_failures do
        expect(mail.subject).to include("LCL Quotation")
        expect(mail.to).to eq(["to@example.org"])
        expect(mail.from).to eq(["support@itsmycargo.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end

      it "renders attaches the pdf and logo" do
        expect(mail.attachments.map(&:filename)).to match_array(%w[logo.png offer.pdf])
      end

      context "when Query is not billable" do
        let(:query) { FactoryBot.build(:journey_query, organization: organization, billable: false) }

        it "renders the subject line with test" do
          expect(mail.subject).to start_with("TEST: ")
        end
      end
    end

    describe "#shipment_request_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:shipment_request) { FactoryBot.create(:journey_shipment_request) }
      let(:mail) do
        described_class.with(
          organization: organization,
          shipment_request: shipment_request,
          recipient: "to@example.org"
        ).shipment_request_created
      end

      it "renders the headers", :aggregate_failures do
        expect(mail.subject).to include("LCL Booking: 20457, Hamburg - Shanghai Airport, Refs: #{shipment_request.result.line_item_sets.first.reference}")
        expect(mail.to).to eq(["to@example.org"])
        expect(mail.from).to eq(["support@itsmycargo.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end
    end
  end
end
