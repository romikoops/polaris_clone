# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe RequestMailer, type: :mailer do
    describe "request_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:query) { FactoryBot.build(:journey_query, organization: organization) }
      let(:request_for_quotation) { FactoryBot.build(:request_for_quotation, organization: organization) }
      let(:subject_line) { "ItsMyCargo RFQ: #{query.load_type.to_s.upcase} / #{query.origin} -> #{query.destination} / #{request_for_quotation.email}" }
      let(:mail) do
        described_class.with(
          organization: organization,
          query: query,
          request_for_quotation: request_for_quotation,
          recipient: "to@example.org"
        ).request_created
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to eq(subject_line)
          expect(mail.to).to eq(["to@example.org"])
          expect(mail.from).to eq([request_for_quotation.email])
        end
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end
    end
  end
end
