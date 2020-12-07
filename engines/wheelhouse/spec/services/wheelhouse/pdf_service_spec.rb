# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::PdfService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user_with_profile, organization: organization) }
  let(:shipment) {
    FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, user: user,
                                        organization: organization)
  }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment) }
  let(:tender_ids) { quotation.tenders.ids }
  let(:pdf_service) { described_class.new(tender_ids: tender_ids, quotation_id: quotation.id) }
  let(:result) { pdf_service.download }

  before do
    ::Organizations.current_id = organization.id
    shipment.charge_breakdowns.map(&:tender).each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
  end

  describe ".download" do
    context "with tender ids" do
      it "returns the Legacy::File" do
        expect(result.file).to be_attached
      end
    end

    context "without tender ids" do
      let(:tender_ids) { [] }

      it "returns the Legacy::File" do
        expect(result.file).to be_attached
      end
    end
  end

  describe ".shipment" do
    context "when shipment is linked to the quotation" do
      it "returns the Legacy::File" do
        expect(pdf_service.send(:shipment)).to eq(shipment)
      end
    end

    context "when shipment is soft deleted" do
      let(:shipment) {
        FactoryBot.create(:legacy_shipment, deleted_at: Time.zone.now, with_tenders: true, user: user,
                                            organization: organization)
      }

      it "returns the shipment" do
        expect(pdf_service.send(:shipment)).to eq(shipment)
      end
    end
  end
end
