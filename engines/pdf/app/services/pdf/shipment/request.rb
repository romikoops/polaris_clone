# frozen_string_literal: true

require "active_storage"
module Pdf
  module Shipment
    class Request < Pdf::Service
      attr_reader :shipment_request

      def initialize(shipment_request:)
        @shipment_request = shipment_request
        super(query: shipment_request.result.query)
      end

      def file
        @file ||= begin
          shipment_request.file.attach(file_arguments)
          shipment_request
        end
      end

      private

      def template
        "shipments/pdfs/shipment_request.pdf.erb"
      end

      def locals_for_generation
        {
          shipment_request: decorated_shipment_request,
          logo: logo,
          organization: organization,
          theme: theme,
          scope: scope
        }
      end

      def decorated_shipment_request
        @decorated_shipment_request ||= ResultFormatter::ShipmentRequestDecorator.new(shipment_request, context: { scope: scope })
      end

      def file_text
        @file_text ||= "shipment_request_#{decorated_shipment_request.result.imc_reference}"
      end
    end
  end
end
