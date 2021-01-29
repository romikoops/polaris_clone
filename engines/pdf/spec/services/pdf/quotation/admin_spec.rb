# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::Quotation::Admin do
  include_context "journey_pdf_setup"

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:offer) do
    FactoryBot.create(:journey_offer, query: query,results: [result])
  end

  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:pdf_service) { described_class.new(offer: offer) }
  let(:pdf) { pdf_service.file }

  describe ".perform" do
    context "when the Offer is provided" do
      it "generates the admin quote pdf", :aggregate_failures do
        expect(pdf).to be_a(Journey::Offer)
        expect(pdf.file).to be_attached
        expect(pdf.file.filename.to_s).to eq("quotation_#{offer.id}.pdf")
      end
    end
  end
end
