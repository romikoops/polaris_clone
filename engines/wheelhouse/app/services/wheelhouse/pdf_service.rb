# frozen_string_literal: true

module Wheelhouse
  class PdfService
    def initialize(quotation_id:, tender_ids: [])
      @tender_ids = tender_ids
      @quotation_id = quotation_id
    end

    def download
      ::Pdf::Service.new(user: shipment.user, organization: shipment.organization)
                    .wheelhouse_quotation(shipment: shipment, tender_ids: tender_ids_for_download)
    end

    private

    attr_reader :quotation_id, :tender_ids

    def shipment
      Legacy::ChargeBreakdown.find_by(tender_id: tender_ids_for_download.first).shipment
    end

    def tender_ids_for_download
      @tender_ids_for_download ||= begin
        return tender_ids if tender_ids.present?

        Quotations::Tender.where(quotation_id: quotation_id).pluck(:id)
      end
    end
  end
end
