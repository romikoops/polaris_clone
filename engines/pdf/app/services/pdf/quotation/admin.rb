# frozen_string_literal: true

require "active_storage"
module Pdf
  module Quotation
    class Admin < Pdf::Service
      attr_reader :quotation

      private

      def file_target
        {target: quotation}
      end

      def tenders
        @tenders ||= Pdf::TenderDecorator.decorate_collection(
          quotation.tenders.order(:amount_cents),
          context: {scope: scope}
        )
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
          target: quotation,
          doc_type: doc_type
        )
      end

      def file_text
        @file_text ||= "quotation_#{tenders.pluck(:imc_reference).join(",")}"
      end
    end
  end
end
