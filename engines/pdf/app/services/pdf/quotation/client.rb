# frozen_string_literal: true

require "active_storage"
module Pdf
  module Quotation
    class Client < Pdf::Service
      attr_reader :quotation

      private

      def doc_type
        "quotation"
      end

      def template
        "shipments/pdfs/quotations.pdf.erb"
      end

      def existing_document
        @existing_document ||= offer.file
      end

      def file_text
        @file_text ||= "offer_#{offer.id}"
      end

      def file_target
        {target: quotation}
      end
    end
  end
end
