# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::Quotation::Client do
  include_context "completed_quotation"

  let(:tender_count) { 3 }
  let(:pdf_service) { described_class.new(quotation: quotations_quotation, tender_ids: tender_ids) }
  let(:pdf) { pdf_service.file }

  describe ".perform" do
    context "when one id is sent" do
      let(:target_tender) { quotations_quotation.tenders.first }
      let(:tender_ids) { [target_tender.id] }

      it "generates the admin quote pdf", :aggregate_failures do
        expect(pdf).to be_a(Legacy::File)
        expect(pdf.file).to be_attached
        expect(pdf.text).to eq("quotation_#{target_tender.imc_reference}")
      end
    end

    context "with all ids" do
      let(:tender_ids) { quotations_quotation.tenders.ids }

      it "generates the quote pdf" do
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    context "with all ids after requesting one" do
      let(:tender_ids) { quotations_quotation.tenders.ids }

      before do
        described_class.new(
          quotation: quotations_quotation,
          tender_ids: [quotations_quotation.tenders.first.id]
        ).file
      end

      it "generates the quote pdf" do
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
          expect(Legacy::File.count).to eq(2)
        end
      end
    end
  end

  context "when it is a LCL shipment" do
    let(:load_type) { "cargo_item" }

    describe ".perform" do
      it "generates the quote pdf" do
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end
  end
end
