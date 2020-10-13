# frozen_string_literal: true

require "active_storage"
module Pdf
  module Shipment
    class Recap < Pdf::Service
      attr_reader :quotation, :shipment

      def initialize(quotation:, shipment:)
        super(quotation: quotation)
        @shipment = shipment
      end

      private

      def tenders
        @tenders ||= Quotations::Tender.where(id: shipment.tender_id)
      end

      def doc_type
        "shipment_recap"
      end

      def template
        "shipments/pdfs/shipment_recap.pdf.html.erb"
      end

      def existing_document
        @existing_document ||= begin
          document = Legacy::File.find_by(
            organization: organization,
            user: user,
            text: file_text,
            shipment: shipment,
            doc_type: doc_type
          )
          return unless document.present? && (shipment.updated_at < document.updated_at && document.file.attached?)

          document
        end
      end

      def locals_for_generation
        {
          quotation: decorated_quotation,
          tender: decorated_tenders.first,
          logo: logo,
          organization: organization,
          theme: theme,
          scope: scope
        }
      end

      def file_text
        @file_text ||= "shipment_#{tenders.pluck(:imc_reference).join(",")}"
      end

      def file_target
        {shipment: shipment}
      end
    end
  end
end
