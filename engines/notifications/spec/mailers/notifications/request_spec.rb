# frozen_string_literal: true
require "rails_helper"

module Notifications
  RSpec.describe RequestMailer, type: :mailer do
    describe "request_created" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:query) { FactoryBot.build(:journey_query, organization: organization) }
      let(:note) { "This is a test note" }
      let(:mode_of_transport) { "ocean" }
      let(:subject_line) { "ItsMyCargo RFQ: #{mode_of_transport.upcase} / #{query.load_type.to_s.upcase} / #{query.origin} -> #{query.destination} / #{query.client.email}" }
      let(:mail) do
        RequestMailer.with(
          organization: organization,
          query: query,
          mode_of_transport: mode_of_transport,
          recipient: "to@example.org"
        ).request_created
      end

      it "renders the headers" do
        aggregate_failures do
          expect(mail.subject).to eq(subject_line)
          expect(mail.to).to eq(["to@example.org"])
          expect(mail.from).to eq([query.client.email])
        end
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Hi")
      end
    end
  end
end
