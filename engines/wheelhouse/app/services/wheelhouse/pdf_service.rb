# frozen_string_literal: true

module Wheelhouse
  class PdfService
    def initialize(quotation_id:, tender_ids: [])
      @tender_ids = tender_ids
      @quotation_id = quotation_id
    end

    def download
      ::Pdf::Quotation::Client.new(quotation: quotation, tender_ids: tender_ids_for_download).file
    end

    private

    attr_reader :quotation_id, :tender_ids

    def shipment
      Legacy::ChargeBreakdown.find_by(tender_id: tender_ids_for_download.first)&.shipment ||
        Legacy::Shipment.with_deleted.find_by(id: quotation.legacy_shipment_id)
    end

    def quotation
      @quotation ||= Quotations::Quotation.find(quotation_id)
    end

    def tender_ids_for_download
      @tender_ids_for_download ||= begin
        return tender_ids if tender_ids.present?

        Quotations::Tender.where(quotation_id: quotation_id).pluck(:id)
      end
    end
  end
end
