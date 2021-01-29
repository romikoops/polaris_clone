# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::QuotationDownloadService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:result_ids) { [result.id] }
  let(:service) { described_class.new(result_ids: result_ids, format: format) }

  describe ".document" do
    let(:pdf_service_double) { double(file: nil) }
    let(:excel_writer_service_double) { double(quotation_sheet: nil) }

    before do
      allow(Pdf::Quotation::Client).to receive(:new).and_return(pdf_service_double)
      allow(Wheelhouse::ExcelWriterService).to receive(:new).and_return(excel_writer_service_double)
    end

    context "when format is not specified" do
      let(:format) { nil }
      it "raises a Missing format error" do
        expect {
          service.document
        }.to raise_error(Wheelhouse::ApplicationError, "Download format is missing or invalid")
      end
    end

    context "with format as pdf" do
      let(:format) { Wheelhouse::QuotationDownloadService::PDF }
      before { service.document }

      it "creates a pdf through the pdf service" do
        expect(pdf_service_double).to have_received(:file)
      end
    end

    context "with format as xlsx" do
      let(:format) { Wheelhouse::QuotationDownloadService::XLSX }
      before { service.document }

      it "creates a quotation xlsx sheet through the excel writer service" do
        expect(excel_writer_service_double).to have_received(:quotation_sheet)
      end
    end
  end
end
