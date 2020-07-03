# frozen_string_literal: true

module Wheelhouse
  class PdfService
    def initialize(tenders:)
      @tenders = tenders
      @shipment = Legacy::ChargeBreakdown.find_by(tender_id: tenders.first[:id]).shipment
    end

    def download
      ::Pdf::Service.new(user: shipment.user, organization: shipment.organization)
                    .wheelhouse_quotation(shipment: shipment, tenders: tenders)
    end

    private

    attr_reader :shipment, :tenders
  end
end
