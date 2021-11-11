# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::Shipment::Request do
  include_context "journey_pdf_setup"

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:shipment_request) do
    FactoryBot.create(:journey_shipment_request,
      result: result,
      client: client,
      company: query.company
    )
  end

  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:pdf_service) { described_class.new(shipment_request: shipment_request) }
  let(:request_with_pdf) { pdf_service.file }

  before do
    FactoryBot.create(:companies_membership, company: query.company, client: client)
    Organizations.current_id = organization.id
  end

  describe "#file" do
    context "when the Offer is provided" do
      it "generates the admin quote pdf", :aggregate_failures do
        expect(request_with_pdf).to be_a(Journey::ShipmentRequest)
        expect(request_with_pdf.file).to be_attached
        expect(request_with_pdf.file.filename.to_s).to eq("shipment_request_#{line_item_set.reference}.pdf")
      end
    end
  end
end
