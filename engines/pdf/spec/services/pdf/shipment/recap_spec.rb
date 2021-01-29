# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::Shipment::Recap do
  include_context "completed_shipment"

  let(:pdf_service) { described_class.new(quotation: quotations_quotation, shipment: shipment) }
  let(:pdf) { pdf_service.file }

  xdescribe ".perform" do
    context "when this is the first time" do
      it "generates the admin quote pdf", :aggregate_failures do
        expect(pdf).to be_a(Legacy::File)
        expect(pdf.file).to be_attached
        expect(pdf.text).to eq("shipment_#{shipment.imc_reference}")
      end
    end

    context "when the shipment has been updated after generating a file" do
      before do
        described_class.new(quotation: quotations_quotation, shipment: shipment).file
        shipment.touch
      end

      it "generates the admin quote pdf" do
        expect(pdf).to be_a(Legacy::File)
        expect(Legacy::File.count).to eq(2)
      end
    end

    context "when the shipment hasnt been updated after generating a file" do
      before do
        described_class.new(quotation: quotations_quotation, shipment: shipment).file
      end

      it "generates the admin quote pdf" do
        expect(pdf).to be_a(Legacy::File)
        expect(Legacy::File.count).to eq(1)
      end
    end
  end

  xcontext "when it is a LCL shipment" do
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
