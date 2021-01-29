# frozen_string_literal: true

require "active_storage"
module Pdf
  module Quotation
    class Admin < Pdf::Service
      attr_reader :quotation

      private

      def doc_type
        "quotation"
      end

      def template
        "shipments/pdfs/quotations.pdf.erb"
      end

      def file_text
        @file_text ||= "quotation_#{offer.id}"
      end
    end
  end
end
