# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::Quotation::Admin do
  include_context "completed_quotation"

  let(:pdf_service) { described_class.new(quotation: quotations_quotation) }
  let(:pdf) { pdf_service.file }

  context "when it is a FCL 20 shipment" do
    let(:load_type) { "container" }

    describe ".perform" do
      it "generates the admin quote pdf" do
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
        end
      end
    end

    describe ".quotation with existing document" do
      before do
        described_class.new(quotation: quotations_quotation).file
      end

      it "generates the quote pdf" do
        aggregate_failures do
          expect(pdf).to be_a(Legacy::File)
          expect(pdf.file).to be_attached
          expect(Legacy::File.count).to eq(1)
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
