# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::QuotationDownloadService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user_with_profile, organization: organization) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, user: user, organization: organization) }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment) }
  let(:tender_ids) { [shipment.charge_breakdowns.first.tender_id] }
  let(:result) { described_class.new(tender_ids: tender_ids, quotation_id: quotation.id, format: format).document }

  describe ".document" do
    let(:pdf_service_double) { double(download: nil) }
    let(:excel_writer_service_double) { double(quotation_sheet: nil) }

    before do
      allow(Wheelhouse::PdfService).to receive(:new).and_return(pdf_service_double)
      allow(Wheelhouse::ExcelWriterService).to receive(:new).and_return(excel_writer_service_double)
    end

    context "when format is not specified" do
      it "raises a Missing format error" do
        expect {
          described_class.new(tender_ids: tender_ids, quotation_id: quotation.id, format: nil).document
        }.to raise_error(Wheelhouse::ApplicationError, "Download format is missing or invalid")
      end
    end

    context "with format as pdf" do
      let(:format) { Wheelhouse::QuotationDownloadService::PDF }

      it "creates a pdf through the pdf service" do
        described_class.new(tender_ids: tender_ids, quotation_id: quotation.id, format: format).document
        expect(pdf_service_double).to have_received(:download)
      end
    end

    context "with format as xlsx" do
      let(:format) { Wheelhouse::QuotationDownloadService::XLSX }

      it "creates a quotation xlsx sheet through the excel writer service" do
        described_class.new(tender_ids: tender_ids, quotation_id: quotation.id, format: format).document
        expect(excel_writer_service_double).to have_received(:quotation_sheet)
      end
    end
  end
end
