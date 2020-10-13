# frozen_string_literal: true

require "active_storage"
module Pdf
  module Quotation
    class Client < Pdf::Service
      attr_reader :quotation

      def initialize(quotation:, tender_ids:)
        super(quotation: quotation)

        @tender_ids = tender_ids
      end

      private

      def tenders
        @tenders ||= begin
          relation = quotation.tenders
          relation = relation.where(id: tender_ids) if tender_ids.present?
          relation.order(:amount_cents)
        end
      end

      def tender_ids
        @tender_ids ||= tender_ids.presence || tenders.ids
      end

      def doc_type
        "quotation"
      end

      def template
        "shipments/pdfs/quotations.pdf.erb"
      end

      def existing_document
        @existing_document ||= Legacy::File.find_by(
          organization: organization,
          user: user,
          text: file_text,
          target: quotation,
          doc_type: doc_type
        )
      end

      def file_text
        @file_text ||= "quotation_#{tenders.pluck(:imc_reference).join(",")}"
      end

      def file_target
        {target: quotation}
      end
    end
  end
end
